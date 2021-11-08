classdef glpcviewer < glCanvas
    % glpcviewer(Locations,Color)
    % glpcviewer(pointCloud)
    %
    % Pointcloud viewer using opengl for rendering
    %
    % Left click: orbit
    % Scroll wheel: zoom
    % Middle click: pan
    % Right click: stop update process (will restart on next movement)
    % ctrl + Left click: display clicked coordinates in console
    
    properties
        figSize
        pos0 % mean of point locations
        ptsPerUpdate = 5e6
        
%         jh
        shaders
        points
        origin
        screen
        
        N % number of point batches
        bposcol % data buffers
        bvalid % validity of data buffers
        
        % rotation translation orbitcenter
        cam = [-45 0 0 0 0 -1 0 0 0];
        camFar
        cam0
        coords0
        button0
        
        clearFlag
        
        updateDepth = 0;
        updateNeeded = 0;
        updating = 0;
        resizeNeeded = 0;
        stopUpdate = 0;
    end
    
    properties(Access=private)
        % temporary data location before being turned into java buffers
        pos 
        col
    end
    
    methods
        function obj = glpcviewer(pos,col)
            if nargin < 2
                cmap = parula(256);
                col = cmap(floor(rescale(pos(:,3)).*255)+1,:);
            end
            n = size(pos,1);
            col = UniformColor(col,n);
%             assert(isfloat(pos),'Location should be in single format');
            assert(isa(col,'uint8'),'Invalid color data');
            assert(size(pos,2)==3,'Location size must be [n x 3]');
            assert(size(col,2)==3,'Color size must be [n x 3], [n x 1], [1 x 3] or [1 x 1]');
            assert(size(pos,1)==size(col,1),'Location and color are not the same length');
            
            rt = java.lang.Runtime.getRuntime;
            rt.gc; % force garbage collect
            memoryAvailable = rt.maxMemory - rt.totalMemory + rt.freeMemory;
            memoryNeeded = n*(3*4+3) + 10e6; % 3*4 bytes for locations + 3 bytes for colors + 10 Mb for overhead
            if memoryAvailable < memoryNeeded
                error(['Data will not fit in heap memory.\nMax: %.2f Mb\nAvailable: %.2f Mb\nNeeded: %.2f Mb\n'...
                    'Provided you have enough system memory, you can use\n'...
                    'com.mathworks.services.Prefs.setIntegerPref(''JavaMemHeapMax'', SizeInMb)\n'...
                    'and restart matlab'],rt.maxMemory/1e6,memoryAvailable/1e6,memoryNeeded/1e6)
            end
            
            obj.pos0 = mean(pos,1,'omitnan');
            obj.pos = single(double(pos) - double(obj.pos0));
            
            obj.col = col;
            
            obj.N = ceil(n/obj.ptsPerUpdate);
            r = max(obj.pos,[],'omitnan') - min(obj.pos,[],'omitnan');
            obj.cam(6) = -max(r)*2;
            
            obj.bposcol = cell(obj.N,2);
            obj.bvalid = false(obj.N,2);
            obj.shaders = glShaders(fullfile(fileparts(mfilename('fullpath')),'shaders'));
            obj.Init(jFrame('GL pcviewer'),'GL4');
            
            obj.setMethodCallback('MousePressed')
            obj.setMethodCallback('MouseReleased')
            obj.setMethodCallback('MouseDragged')
            obj.setMethodCallback('MouseWheelMoved')
            obj.setMethodCallback('ComponentResized')
            obj.frame.setCallback('WindowClosing',@obj.WindowClosing);
            
            obj.Update;
        end
        
        function InitFcn(obj,d,gl)
            temppos = zeros(3,obj.ptsPerUpdate,'like',obj.pos);
            tempcol = zeros(3,obj.ptsPerUpdate,'uint8');
            
            obj.points = glElement(gl,{temppos,tempcol},'pointcloud',obj.shaders,gl.GL_POINTS,gl.GL_STREAM_DRAW,[gl.GL_FALSE gl.GL_TRUE]);
            
            temppos = single([0 0 0 ; 1 0 0 ; 0 0 0 ; 0 1 0 ; 0 0 0 ; 0 0 1]');
            tempcol = single([1 0 0 ; 1 0 0 ; 0 1 0 ; 0 1 0 ; 0 0 1 ; 0 0 1]');
            obj.origin = glElement(gl,{temppos,tempcol},'pointcloud',obj.shaders,gl.GL_LINES);
            obj.origin.uni.Int1.info_type = 1;
            obj.origin.uni.Mat4.model = eye(4,'single');
            
            quadVert = single([-1 -1 0 0; -1 1 0 1; 1 -1 1 0; 1 1 1 1]');            
            obj.screen = glElement(gl,quadVert,'screen',obj.shaders,gl.GL_TRIANGLE_STRIP);
            obj.screen.AddTexture(gl,0,gl.GL_TEXTURE_2D,[],[],gl.GL_LINEAR,gl.GL_LINEAR);
            obj.shaders.SetInt1(gl,'screen','colorTex',0);
            obj.screen.AddTexture(gl,1,gl.GL_TEXTURE_2D,[],[],gl.GL_NEAREST,gl.GL_NEAREST);
            obj.shaders.SetInt1(gl,'screen','infoTex',1);
            
            obj.clearFlag = glFlags(gl,'GL_COLOR_BUFFER_BIT','GL_DEPTH_BUFFER_BIT');
            
            gl.glEnable(gl.GL_VERTEX_PROGRAM_POINT_SIZE);
            gl.glDrawBuffer(gl.GL_FRONT);
            gl.glClearColor(0,0,0,0);
%             gl.glLineWidth(2)
            
            obj.figSize = [obj.gc.getWidth,obj.gc.getHeight];
            
            obj.ResizeFcn(d,gl);
            
            obj.screen.SetFramebuffer(gl,gl.GL_DEPTH_ATTACHMENT);
        end
        
        function UpdateFcn(obj,d,gl)
            % execute java callback queue and return if an update is already in progress
            obj.updateNeeded = 1;
            obj.stopUpdate = 0;
%             [d,gl] = obj.glDrawnow;
            if obj.updating, return, end
            obj.updating = 1;
            while obj.updateNeeded
%                 tic
                if obj.resizeNeeded
                    obj.ResizeFcn(d,gl);
                    obj.resizeNeeded=0;
                end
                
                obj.updateNeeded = 0;
                obj.screen.UseFramebuffer(gl);
                gl.glEnable(gl.GL_DEPTH_TEST);

                gl.glClear(obj.clearFlag);
                
                near = clip(-obj.cam(6)/10,0.01,1);
                far = clip(-obj.cam(6)*10,10,1e6);

                mP = MTransform('P',[[obj.figSize/mean(obj.figSize) 1].*near far]);
                obj.shaders.SetMat4(gl,'pointcloud','projection',single(mP));

                mV = MTransform('T',obj.cam(4:6))*MTransform('RR',obj.cam(1:3),1);
                obj.shaders.SetMat4(gl,'pointcloud','view',single(mV));
                
%                 mVP = mP*mV;
                
%                 mR = MTransform('R',[0 46 -71],1)';
%                 obj.shaders.SetMat4(gl,'pointcloud','view',single(mVP));
                obj.origin.Draw(gl);
                mM = MTransform('T',-obj.cam(7:9));
%                 mM = mR*MTransform('T',-obj.cam(7:9));
                obj.shaders.SetMat4(gl,'pointcloud','model',single(mM));
%                 obj.shaders.SetMat4(gl,'pointcloud','view',single(mVP*mM));
                
                
%                 obj.shaders.SetFloat1(gl,'pointcloud','info_type',2);
                obj.shaders.SetInt1(gl,'pointcloud','info_type',2);
%                 obj.cam
                if all(obj.bvalid(:,1))
                    k = [1 randperm(obj.N-1)+1];
                else
                    k = 1:obj.N;
                end
                
                for i=k
                    if ~obj.bvalid(i,1)
                        obj.bposcol{i,1} = javabuffer(obj.pos(i:obj.N:end,:)');
                        obj.bvalid(i,1) = 1;
                        if all(obj.bvalid(:,1))
                            obj.pos = [];
                        end
                    end
                    if ~obj.bvalid(i,2)
                        obj.bposcol{i,2} = javabuffer(obj.col(i:obj.N:end,:)');
                        obj.bvalid(i,2) = 1;
                        if all(obj.bvalid(:,2))
                            obj.col = [];
                        end
                    end
                    obj.screen.UseFramebuffer(gl);
%                     gl.glEnable(gl.GL_MULTISAMPLE);
                    gl.glEnable(gl.GL_DEPTH_TEST);

                    obj.points.EditData(gl,obj.bposcol(i,:),true)
%                     obj.shaders.SetFloat1(gl,'pointcloud','info_idx',i);
                    obj.shaders.SetInt1(gl,'pointcloud','info_idx',i);
                    obj.points.Draw(gl);
                    
                    gl.glBindFramebuffer(gl.GL_FRAMEBUFFER,0);
                    gl.glDisable(gl.GL_DEPTH_TEST);
                    gl.glClear(gl.GL_COLOR_BUFFER_BIT);
                    
                    obj.screen.Draw(gl);
                    
                    gl.glFlush
                    pause(0.1)
                    [d,gl] = obj.glDrawnow;
                    if obj.stopUpdate, return, end
                    if obj.updateNeeded, break, end
                    
                end
%                 1/toc
            end
            obj.updating = 0;
        end
        
        function ResizeFcn(obj,d,gl)
            sz = obj.figSize;
            
            obj.screen.EditTex(gl,0,{0,gl.GL_RGB,sz(1),sz(2),0,gl.GL_RGB,gl.GL_UNSIGNED_BYTE,[]});
            obj.screen.EditTex(gl,1,{0,gl.GL_RGBA32I,sz(1),sz(2),0,gl.GL_RGBA_INTEGER,gl.GL_INT,[]});
            obj.screen.EditRenderbuffer(gl,gl.GL_DEPTH_COMPONENT32F,sz);
            
            gl.glViewport(0,0,sz(1),sz(2));
            
            obj.shaders.SetVec2(gl,'screen','scrSz',single(sz));
            
        end
        
        function MousePressed(obj,src,evt)
            obj.button0 = evt.getButton;
            if evt.getButton == 3
                obj.stopUpdate = 1;
            else
                obj.coords0 = [evt.getX evt.getY];
                p = obj.glFcn(@obj.glGetPoint);
                if evt.getModifiers == 18 && ~isempty(p)
                    fprintf('Point coords: %.3f, %.3f, %.3f\n',double(p)+obj.pos0);
                end
                obj.setFocus(p);
                obj.cam0 = obj.cam;
            end
            obj.Update
        end
        
        function MouseReleased(obj,src,evt)
            obj.button0 = 0;
        end
        
        function p = glGetPoint(obj,d,gl)
%             p = []; return
            obj.screen.UseFramebuffer(gl);
            gl.glReadBuffer(gl.GL_COLOR_ATTACHMENT1);
%             gl.glReadBuffer(gl.GL_FRONT);
            
            w = 5; h = 5; n = 4;
            
            b = javabuffer(zeros(w*h*n,1,'int32'));
%             p = [];
%             return
            gl.glReadPixels(obj.coords0(1),obj.gc.getHeight-obj.coords0(2),w,h,gl.GL_RGBA_INTEGER,gl.GL_INT,b);
            info = reshape(b.array,n,w*h)';
            k = info(:,3) > 0 & info(:,1) == 2;
            p = [];
            if any(k)
                info = info(k,:);
                [~,k] = min(info(:,4));
                b = obj.bposcol{info(k,2),1};
                i = info(k,3)*3;
                p = arrayfun(@(a) b.get(i+a),0:2);
                b.rewind;
            end         
        end
        
        function setFocus(obj,p)
            if isempty(p), return, end
            obj.cam(4:6) = obj.cam(4:6) + (p-obj.cam(7:9))*MRot(obj.cam(1:3),1,1)';
            obj.cam(7:9) = p;
        end
        
        function setPointSizes(obj,distPt,maxSize)
            % distPt: distance from which point start to grow
            % maxSize: maximum point size, in pixels
            obj.glFcn(@obj.glSetPointSizes,distPt,maxSize);
            obj.Update;
        end
        
        function glSetPointSizes(obj,d,gl,distPt,maxSize)
            obj.shaders.SetFloat1(gl,'pointcloud','pointSizeDist',distPt);
            obj.shaders.SetFloat1(gl,'pointcloud','maxPointSize',maxSize);
        end
        
        function MouseDragged(obj,src,evt)
            dcoords = [evt.getX evt.getY] - obj.coords0;
            switch obj.button0
                case 1
                    obj.cam([3 1]) = obj.cam0([3 1])+dcoords/5;
                case 2
                    obj.cam([4 5]) = obj.cam0([4 5])+dcoords.*[-1 1]./mean(obj.figSize).*obj.cam0(6);
                otherwise
                    return
            end
            obj.Update;
        end
        
        function MouseWheelMoved(obj,src,evt)
            s = evt.getUnitsToScroll / 50;
            obj.coords0 = [evt.getX evt.getY];
            p = obj.glFcn(@obj.glGetPoint);
            obj.setFocus(p);
            obj.cam(4:6) = obj.cam(4:6)+obj.cam(4:6).*s;
            obj.Update;
        end
        
        function ComponentResized(obj,src,evt)
            obj.figSize = [obj.gc.getWidth,obj.gc.getHeight];
            obj.resizeNeeded = 1;
            obj.Update;
        end
        
        function WindowClosing(obj,src,evt)
            obj.stopUpdate = 1;
            obj.glStop = 1;
        end
        
    end
end

function c = UniformColor(c,n)
    if ~isinteger(c)
        c = uint8(c.*255);
    end
    
    if ~isa(c,'uint8')
        c = uint8(single(c)./single(c(1)+inf).*255);
    end
    
    if size(c,1) == 1
        % unicolor
        c = repmat(c,n,1);
    end
    if size(c,2) == 1
        % intensity
        c = repmat(c,1,3);
    end
end


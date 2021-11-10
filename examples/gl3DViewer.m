classdef gl3DViewer < glCanvas
    
    properties
        figSize
        pos0 % mean of point locations
        
        pos
        col
        idx
        cmap
        
        MView single
        MProj single
        
        shaders
        points
        origin
        screen
        
        % rotation translation orbitcenter
        cam = [-45 0 -45 0 0 -1 0 0 0];
        click = struct('button',0)
        
        clearFlag
        
        updateNeeded = 0;
        resizeNeeded = 0;
        updating = 0;
    end
    
    methods
        function obj = gl3DViewer(pos,col,cmap,T)
            if nargin < 2 || isempty(col)
                col = floor(rescale(pos(:,3)).*255+1);
            end
            if nargin < 3 || isempty(cmap), cmap = parula(256); end
            if nargin < 4, T = []; end

            n = size(pos,1);
            col = UniformColor(col,n,cmap);

            assert(isa(col,'uint8'),'Invalid color data');
            assert(size(pos,2)==3,'Location size must be [n x 3]');
            assert(size(col,2)==3,'Color size must be [n x 3], [n x 1], [1 x 3] or [1 x 1]');
            assert(size(pos,1)==size(col,1),'Location and color are not the same length');
            
            obj.pos0 = mean(pos,1,'omitnan');
            obj.pos = single(double(pos) - double(obj.pos0));
            obj.col = col;
            if nargin >= 4
                obj.idx = T;
            end
            
            r = range(obj.pos);
            obj.cam(6) = -max(r)*2;

            obj.cmap = cmap;
            
            obj.shaders = glShaders(fullfile(fileparts(mfilename('fullpath')),'shaders'));
            obj.Init(jFrame('GL 3D Viewer'),'GL4');
            
            obj.setMethodCallback('MousePressed')
            obj.setMethodCallback('MouseReleased')
            obj.setMethodCallback('MouseDragged')
            obj.setMethodCallback('MouseWheelMoved')
            obj.setMethodCallback('ComponentResized')
            obj.frame.setCallback('WindowClosing',@obj.WindowClosing);
            
            obj.Update;
        end
        
        function InitFcn(obj,d,gl)
            if isempty(obj.idx), drawMode = 'GL_POINTS'; else, drawMode = 'GL_TRIANGLES'; end
            obj.points = glElement(gl,{obj.pos',obj.col'},'pointcloud',obj.shaders,gl.(drawMode),gl.GL_STATIC_DRAW,[gl.GL_FALSE gl.GL_TRUE]);

            if ~isempty(obj.idx)
                obj.points.SetIndex(gl,obj.idx');
            end
            
            obj.points.uni.Mat4.model = eye(4,'single');

            temppos = single([0 0 0 ; 1 0 0 ; 0 0 0 ; 0 1 0 ; 0 0 0 ; 0 0 1]');
            tempcol = single([1 0 0 ; 1 0 0 ; 0 1 0 ; 0 1 0 ; 0 0 1 ; 0 0 1]');
            obj.origin = glElement(gl,{temppos,tempcol},'pointcloud',obj.shaders,gl.GL_LINES);
%             obj.origin.uni.Int1.info_type = 1;
            obj.origin.uni.Mat4.model = eye(4,'single');
            
            quadVert = single([-1 -1 0 0; -1 1 0 1; 1 -1 1 0; 1 1 1 1]');
            obj.screen = glElement(gl,quadVert,'screen',obj.shaders,gl.GL_TRIANGLE_STRIP);
            obj.screen.AddTexture(gl,0,gl.GL_TEXTURE_2D,[],[],gl.GL_LINEAR,gl.GL_LINEAR);
            obj.shaders.SetInt1(gl,'screen','colorTex',0);
            obj.screen.AddTexture(gl,1,gl.GL_TEXTURE_2D,[],[],gl.GL_LINEAR,gl.GL_LINEAR);
            obj.shaders.SetInt1(gl,'screen','infoTex',1);
            
            obj.clearFlag = glFlags(gl,'GL_COLOR_BUFFER_BIT','GL_DEPTH_BUFFER_BIT');
            
            gl.glClearColor(0,0,0,0);
            
            obj.figSize = [obj.gc.getWidth,obj.gc.getHeight];
            
            obj.ResizeFcn(d,gl);
            
            obj.screen.SetFramebuffer(gl,gl.GL_DEPTH_ATTACHMENT);
        end
        
        function UpdateFcn(obj,d,gl)
            obj.updateNeeded = 1;
            if obj.updating, return, end
            obj.updating = 1; temp = onCleanup(@() obj.EndUpdate);
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
                
                near = clamp(-obj.cam(6)/10,0.01,1);
                far = clamp(-obj.cam(6)*10,10,1e6);
                
                s = obj.figSize;
                obj.MProj = MProj3D('P',[[s/mean(s) 1].*near far]);
                obj.shaders.SetMat4(gl,'pointcloud','projection',obj.MProj);
                
                obj.MView = MTrans3D(obj.cam(4:6)) * MRot3D(obj.cam(1:3),1,[1 3]) * MTrans3D(-obj.cam(7:9));
                obj.shaders.SetMat4(gl,'pointcloud','view',obj.MView);
%                 mVP = mP*mV;
                
%                 mR = MTransform('R',[0 46 -71],1)';
%                 obj.shaders.SetMat4(gl,'pointcloud','view',single(mVP));
                if obj.click.button
                    obj.origin.Draw(gl);
                end
                obj.screen.UseFramebuffer(gl);
%                     gl.glEnable(gl.GL_MULTISAMPLE);
                gl.glEnable(gl.GL_DEPTH_TEST);

%                     obj.points.EditData(gl,obj.bposcol(i,:),true)
%                     obj.shaders.SetFloat1(gl,'pointcloud','info_idx',i);
%                     obj.shaders.SetInt1(gl,'pointcloud','info_idx',i);
                obj.points.Draw(gl);
                
                gl.glBindFramebuffer(gl.GL_FRAMEBUFFER,0);
                gl.glDisable(gl.GL_DEPTH_TEST);
                gl.glClear(gl.GL_COLOR_BUFFER_BIT);
                obj.screen.Draw(gl);
                
                d.swapBuffers;
                [d,gl] = obj.glDrawnow;
%                 1/toc
            end
        end
        
        function EndUpdate(obj)
            obj.updating = 0;
        end
        
        function ResizeFcn(obj,d,gl)
            sz = obj.figSize;
            
            obj.screen.EditTex(gl,0,{0,gl.GL_RGB,sz(1),sz(2),0,gl.GL_RGB,gl.GL_UNSIGNED_BYTE,[]});
            obj.screen.EditTex(gl,1,{0,gl.GL_RGBA32F,sz(1),sz(2),0,gl.GL_RGBA,gl.GL_FLOAT,[]});
            obj.screen.EditRenderbuffer(gl,gl.GL_DEPTH_COMPONENT32F,sz);
            
            gl.glViewport(0,0,sz(1),sz(2));
            
            obj.shaders.SetVec2(gl,'screen','scrSz',single(sz));
            
        end
        
        function MousePressed(obj,src,evt)
            obj.click.button = evt.getButton;
            if evt.getButton == 3
%                 obj.stopUpdate = 1;
            else
                c = [evt.getX evt.getY];
                obj.click.coords = c;
                p = obj.glFcn(@obj.glGetPoint,c);
                if evt.getModifiers == 18 && ~isempty(p)
                    fprintf('Point coords: %.3f, %.3f, %.3f\n',double(p)+obj.pos0);
                end
                obj.setFocus(p);
                obj.click.cam = obj.cam;
            end
            obj.Update
        end
        
        function MouseReleased(obj,src,evt)
            obj.click.button = 0;
            obj.Update;
        end
        
        function p = glGetPoint(obj,d,gl,c)
            obj.screen.UseFramebuffer(gl);
            gl.glReadBuffer(gl.GL_NONE);
            
            r = 2; % click radius (square box) px
            w = 2*r+1; % square side length px
            
            b = javabuffer(zeros(w*w,1,'single'));
            
            s = obj.figSize;
            c(2) = s(2) - c(2);
            
            gl.glReadPixels(c(1)-r,c(2)-r,w,w,gl.GL_DEPTH_COMPONENT,gl.GL_FLOAT,b);
            depth = reshape(b.array,w,w);
            
            p = [];
            n = depth == 1;
            if all(n,'all'), return, end % no valid points in click box
            depth(n) = nan;
            depth = rot90(depth);
%             imagesc(depth)
            [~,k] = min(depth,[],'all');
            [y,x] = ind2sub([w w],k);
            
            % normalized device coordinates
            NDC = [(c+[x-r-0.5 r-y+1.5])./s depth(k) 1]'.*2-1;
            
            % world coordinates
            WC = obj.MProj * obj.MView \ NDC;
            WC = WC(1:3)'./WC(4);
            
            if ~any(isnan(WC))
                obj.origin.uni.Mat4.model = MTrans3D(WC);
                p = WC;
            end
        end
        
        function setFocus(obj,p)
            if isempty(p), return, end
            obj.cam(4:6) = obj.cam(4:6) + (p-obj.cam(7:9))*MRot(obj.cam(1:3),1,1)';
            obj.cam(7:9) = p;
        end
        
        function MouseDragged(obj,src,evt)
            dcoords = [evt.getX evt.getY] - obj.click.coords;
            switch obj.click.button
                case 1
                    % rotation 0.2 deg/pixel
                    obj.cam([3 1]) = obj.click.cam([3 1])+dcoords/5;
                case 2
                    % 
                    obj.cam([4 5]) = obj.click.cam([4 5])+dcoords.*[-1 1]./mean(obj.figSize).*obj.click.cam(6);
                otherwise
                    return
            end
            obj.Update;
        end
        
        function MouseWheelMoved(obj,src,evt)
            s = evt.getUnitsToScroll / 50;
            p = obj.glFcn(@obj.glGetPoint,[evt.getX evt.getY]);
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
            obj.glStop = 1;
        end
        
    end
end

function c = UniformColor(c,n,cmap)
    if size(c,2) == 1
        % colormap
        cmap = single(cmap);
        c = uint8(cmap(round(c),:).*255);
    else
        % color
        if ~isinteger(c)
            c = uint8(c.*255);
        end

        if ~isa(c,'uint8')
            c = uint8(single(c)./single(c(1)+inf).*255);
        end
    end

    if size(c,1) == 1
        c = repmat(c,n,1);
    end

end


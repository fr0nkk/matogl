classdef glViewer3D < glCanvas
    % View point cloud or meshes with opengl render
    % glViewer3D(pos) : view point cloud with color scaled on Z coords
    %   pos must be [n x 3] where n is the number of points
    % glViewer3D(pos,col) : view point cloud with user set color
    %   col can be:
    %     [n x 1] : color will be gray scale
    %     [n x 3] : each point will have its RGB color
    %     [1 x 3] : every point will have the same RGB color
    %     [] (empty): same as gl3DViewer(pos)
    %     floating point range: 0 to 1
    %     integer range: 0 to intmax
    % glViewer3D(pos,col,idx)
    %    idx is the triangle list, in point indices (starting at 0)
    %      if using matlab functions like delaunay(), use (idx-1)
    % glViewer3D(___,'edl',edlStrength)
    %    Set EDL strength for simulated light. Set to 0 to deactivate
    %
    % Left click: orbit
    % Right click: pan
    % scroll wheel: zoom
    % scroll click: zoom
    % ctrl + left click: display clicked coords in console
    %   *clicked coords are not 100% accurate since they are recalculated
    %   from the inverse projection.
    % ctrl + middle click: adjust focal length
    % ctrl + right click: adjust EDL strength
    %
    % To take a snapshot:
    % v = glViewer3D( ... )
    % img = v.Snapshot; % puts current view into img variable
    % v.Snapshot; % creates imshow(img)
    
    properties
        figSize
        pos0 % mean of point locations
        
        ptcloudProgram
        framebuffer
%         ama
        points
        axe
        screen
        
        cam % glmu.Camera3D
        edl0 = 0.1
        
        clearFlag
    end
    
    methods
        function obj = glViewer3D(pos,varargin)
            if nargin < 1
                % test example - 160k points, 318k triangles
                [X,Y,Z] = peaks(400);

                % example with membrane instead of peaks
%                 n = 100;
%                 a = linspace(0,1,2*n+1);
%                 [X,Y] = ndgrid(a,a);
%                 Z = membrane(1,n);

                pos = [X(:) Y(:) Z(:)];
                clear X Y Z
                T = delaunay(pos(:,1:2));
                varargin{2} = T-1;
            end
            p = inputParser;
            p.addOptional('col',[]);
            p.addOptional('idx',[]);
            p.addParameter('edl',obj.edl0);
            p.parse(varargin{:});
            
            col = p.Results.col;
            if isempty(col)
                col = floor(rescale(pos(:,3)).*255+1);
                cmap = jet(256);
                col = cmap(col,:);
            end

            n = size(pos,1);
            col = PreprocColor(col,n);

            assert(isa(col,'uint8'),'Invalid color data');
            assert(size(pos,2)==3,'Location size must be [n x 3]');
            assert(size(col,2)==3,'Color size must be [n x 3], [n x 1], [1 x 3] or [1 x 1]');
            assert(size(pos,1)==size(col,1),'Location and color are not the same length');
            
            obj.pos0 = mean(pos,1,'omitnan');
            pos = single(double(pos) - double(obj.pos0));
            
            obj.Init(jFrame('GL 3D Viewer'),'GL3',0,pos,col,p.Results.idx,p.Results.edl);
            
            obj.setMethodCallback('MousePressed');
            obj.setMethodCallback('MouseReleased');
            obj.setMethodCallback('MouseDragged');
            obj.setMethodCallback('MouseWheelMoved');
            obj.parent.setCallback('WindowClosing',@obj.WindowClosing);
        end
        
        function InitFcn(obj,~,gl,pos,col,idx,edl)
            glmu.SetResourcesPath(fileparts(mfilename('fullpath')));
            glAssertNoError(gl);

            obj.ptcloudProgram = glmu.Program('pointcloud');
            glAssertNoError(gl);
            u = obj.ptcloudProgram.uniforms;
            obj.cam = glmu.Camera3D(u.projection,u.view);
            glAssertNoError(gl);
            buf = {pos',col'};
            norm = [false true];

            if isempty(idx)
                obj.points = glmu.drawable.Array(obj.ptcloudProgram,gl.GL_POINTS,buf,norm);
            else
                obj.points = glmu.drawable.Element(obj.ptcloudProgram,gl.GL_TRIANGLES,idx',buf,norm);
            end
            glAssertNoError(gl);
%             obj.ama = glmu.drawable.AutoMultiArray('pointcloud',gl.GL_POINTS,[0 1],[3 3],[gl.GL_FLOAT gl.GL_UNSIGNED_BYTE],[false true]);
%             for i=1:100
%                 id = obj.ama.AddData({pos' + [0 0 i]',col'});
%             end
            obj.points.uni.model = eye(4);

            camDist = double(max(max(pos,[],1) - min(pos,[],1)));
            if camDist > 0
                obj.cam.viewParams.T(3) = -camDist*2;
            end

            axe_pos = single([0 0 0 ; 1 0 0 ; 0 0 0 ; 0 1 0 ; 0 0 0 ; 0 0 1]');
            axe_col = single([1 0 0 ; 1 0 0 ; 0 1 0 ; 0 1 0 ; 0 0 1 ; 0 0 1]');

            obj.axe = glmu.drawable.Array(obj.ptcloudProgram,gl.GL_LINES,{axe_pos,axe_col});
            glAssertNoError(gl);

            obj.axe.uni.model = eye(4);
            obj.axe.show = 0;
            
            quadVert = single([-1 -1 0 0; -1 1 0 1; 1 -1 1 0; 1 1 1 1]');
            obj.screen = glmu.drawable.Array('screen',gl.GL_TRIANGLE_STRIP,quadVert);
            glAssertNoError(gl);

            T = glmu.Texture(0,gl.GL_TEXTURE_2D);
            glAssertNoError(gl);

            obj.screen.AddTexture('colorTex',T);
            glAssertNoError(gl);

            obj.screen.program.uniforms.edlStrength.Set(edl);
            glAssertNoError(gl);
            
            obj.clearFlag = glmu.BitFlags('GL_COLOR_BUFFER_BIT','GL_DEPTH_BUFFER_BIT');
            glAssertNoError(gl);
            
            gl.glClearColor(0,0,0,0);
            glAssertNoError(gl);
            gl.glReadBuffer(gl.GL_FRONT);
            glAssertNoError(gl);
            
            renderbuffer = glmu.Renderbuffer(gl.GL_DEPTH_COMPONENT32F);
            glAssertNoError(gl);
            renderbuffer.AddTexture(T,gl.GL_FLOAT,gl.GL_RGBA,gl.GL_RGBA32F);
            glAssertNoError(gl);
            obj.framebuffer = glmu.Framebuffer(gl.GL_FRAMEBUFFER,renderbuffer,gl.GL_DEPTH_ATTACHMENT);
            glAssertNoError(gl);
        end
        
        function UpdateFcn(obj,d,gl)
            % render to texture
%             tic
            obj.framebuffer.Bind;
            glAssertNoError(gl);
            
            gl.glEnable(gl.GL_DEPTH_TEST);
            glAssertNoError(gl);
            gl.glClear(obj.clearFlag);
            glAssertNoError(gl);
            
            camDist = -obj.cam.viewParams.T(3);
            near = clamp(camDist/10,1e-3,1);
            far = clamp(camDist*10,100,1e6);
            obj.cam.SetNearFar(near,far);
            glAssertNoError(gl);

            obj.cam.Update;
            glAssertNoError(gl);
            obj.axe.Draw;
            glAssertNoError(gl);
            obj.points.Draw;
            glAssertNoError(gl);
%             obj.ama.Draw;

            % render to screen
            obj.framebuffer.Release;
            glAssertNoError(gl);

            gl.glDisable(gl.GL_DEPTH_TEST);
            glAssertNoError(gl);
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            glAssertNoError(gl);
            obj.screen.Draw;
            glAssertNoError(gl);
            
            d.swapBuffers;
%             1/toc
        end
        
        function ResizeFcn(obj,~,gl)
            sz = [obj.java.getWidth,obj.java.getHeight];
            obj.figSize = sz;
            obj.cam.Resize(sz);
            glAssertNoError(gl);
            obj.framebuffer.Resize(sz);
            glAssertNoError(gl);
            
            gl.glViewport(0,0,sz(1),sz(2));
            glAssertNoError(gl);
            
            obj.screen.program.uniforms.scrSz.Set(sz);
            glAssertNoError(gl);
        end
        
        function MousePressed(obj,~,evt)
            c = getEvtXY(evt);
            p = obj.glFcn(@obj.glGetPoint,c);

            if bitand(evt.CTRL_MASK,evt.getModifiers) && ~isempty(p) % ctrl pressed
                fprintf('Point coords: %.3f, %.3f, %.3f\n',double(p)+obj.pos0');
            end
            obj.edl0 = obj.screen.program.uniforms.edlStrength.lastValue;
            obj.cam.SetRotationOrigin(p);
            obj.cam.MousePressed(evt);
            obj.axe.show = 1;
            obj.Update
        end
        
        function MouseReleased(obj,~,evt)
            obj.cam.MouseReleased(evt);
            obj.axe.show = any(obj.cam.click.button);
            obj.Update;
        end

        function img = Snapshot(obj)
            img = obj.glFcn(@obj.glGetImg);
            if nargout == 0
                figure('Name','glViewer3D.Snapshot','NumberTitle','off');
                img = imshow(img);
            end
        end

        function img = glGetImg(obj,d,gl)
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER,0);
            w = obj.java.getWidth;
            h = obj.java.getHeight;
            
            gl.glPixelStorei(gl.GL_PACK_ALIGNMENT,1);
            b = javabuffer(zeros(3,w,h,'uint8'));
            gl.glReadPixels(0,0,w,h,gl.GL_RGB, gl.GL_UNSIGNED_BYTE, b.p);
            img = b.array;
            img = permute(img,[2 3 1]);
            img = rot90(img);
        end
        
        function WC = glGetPoint(obj,~,gl,c)
            obj.framebuffer.Bind;
            
            r = 2; % click radius (square box) px
            w = 2*r+1; % square side length px
            
            b = javabuffer(zeros(w,w,'single'));
            
            s = obj.figSize';
            c(2) = s(2) - c(2);
            
            gl.glReadPixels(c(1)-r,c(2)-r,w,w,gl.GL_DEPTH_COMPONENT,gl.GL_FLOAT,b.p);
            depth = double(b.array);

            n = depth == 1;

            if all(n,'all')
                % no valid points in click box
                % returned point will be same as before but without cam xy translation
                v = obj.cam.viewParams;
                WC = MTrans3D([v.T(1:2) ; 0]) * MRot3D(v.R,1,[1 3]) * MTrans3D(-v.O) \ [0 0 0 1]';
            else
                depth(n) = nan;
                depth = rot90(depth);
                
                [~,k] = min(depth(:));
                [y,x] = ind2sub([w w],k);
                
                % normalized device coordinates
                NDC = [(c+[x-r-0.5 ; r-y+1.5])./s ; depth(k) ; 1].*2-1;
                
                % world coordinates
                WC = obj.cam.MProj * obj.cam.MView \ NDC;
                
                if any(isnan(WC))
                    WC = [];
                    return
                end
            end
            WC = WC(1:3)./WC(4);
            obj.axe.uni.model = MTrans3D(WC);
        end

        function SetEDL(obj,edl)
            [~,gl,temp] = obj.getContext; %#ok<ASGLU> temp is onCleanup()
            obj.screen.program.uniforms.edlStrength.Set(edl);
        end
        
        function MouseDragged(obj,~,evt)
            if obj.cam.click.button(3) && bitand(evt.getModifiers,evt.CTRL_MASK)
                % ctrl + right click
                dxy = obj.cam.GetDxy(evt);
                s = 2^(dxy(2)./100);
                obj.SetEDL(obj.edl0.*s);
            else
                obj.cam.MouseDragged(evt);
            end
            obj.Update;
        end
        
        function MouseWheelMoved(obj,~,evt)
            p = obj.glFcn(@obj.glGetPoint,getEvtXY(evt));
            obj.cam.SetRotationOrigin(p);
            obj.cam.MouseWheelMoved(evt);
            obj.Update;
        end
        
        function WindowClosing(obj,~,~)
            obj.glStop = 1;
        end
        
    end
end

function c = PreprocColor(c,n)
    if size(c,2) == 1
        % gray tones
        c = repmat(c,1,3);
    end

    if ~isinteger(c)
        % floating point 0 to 1
        c = uint8(c.*255);
    end

    if ~isa(c,'uint8')
        % integer that is not uint8
        c = uint8(single(c)./single(c(1)+inf).*255);
    end

    if size(c,1) == 1
        % uniform color
        c = repmat(c,n,1);
    end
end

function xy = getEvtXY(evt)
    xy = [evt.getX evt.getY]';
end


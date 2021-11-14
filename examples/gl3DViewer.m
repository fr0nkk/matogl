classdef gl3DViewer < glCanvas
    % View point cloud or meshes with opengl render
    % gl3DViewer(pos) : view point cloud with color scaled on Z coords
    %   pos must be [n x 3] where n is the number of points
    % gl3DViewer(pos,col) : view point cloud with user set color
    %   col can be:
    %     [n x 1] : color will be gray scale
    %     [n x 3] : each point will have its RGB color
    %     [1 x 3] : every point will have the same RGB color
    %     [] (empty): same as gl3DViewer(pos)
    %     floating point range: 0 to 1
    %     integer range: 0 to intmax
    % gl3DViewer(pos,col,idx)
    %    idx is the triangle list, in point indices (starting at 0)
    %      if using matlab functions like delaunay(), use (idx-1)
    %
    % Left click: rotate
    % Right click: translate
    % scroll wheel: zoom
    % ctrl + left click: display clicked coords in console
    %   *clicked coords are not 100% accurate since they are recalculated
    %   from the inverse projection.
    
    properties
        figSize
        pos0 % mean of point locations
        
        MView single
        MProj single
        
        shaders

        points
        origin
        screen
        
        % rotation translation orbitcenter
        cam = [-45 0 -45 0 0 -1 0 0 0];
        click = struct('button',0,'coords',[0 0],'cam',[0 0 0 0 0 -1 0 0 0])
        
        clearFlag
    end
    
    methods
        function obj = gl3DViewer(pos,col,idx)
            if nargin < 2 || isempty(col)
                col = floor(rescale(pos(:,3)).*255+1);
                cmap = jet(256);
                col = cmap(col,:);
            end
            if nargin < 3, idx = []; end

            n = size(pos,1);
            col = UniformColor(col,n);

            assert(isa(col,'uint8'),'Invalid color data');
            assert(size(pos,2)==3,'Location size must be [n x 3]');
            assert(size(col,2)==3,'Color size must be [n x 3], [n x 1], [1 x 3] or [1 x 1]');
            assert(size(pos,1)==size(col,1),'Location and color are not the same length');
            
            obj.pos0 = mean(pos,1,'omitnan');
            pos = single(double(pos) - double(obj.pos0));            
            
            obj.shaders = glShaders(fullfile(fileparts(mfilename('fullpath')),'shaders'));
            obj.Init(jFrame('GL 3D Viewer'),'GL4',0,pos,col,idx);
            
            obj.setMethodCallback('MousePressed')
            obj.setMethodCallback('MouseReleased')
            obj.setMethodCallback('MouseDragged')
            obj.setMethodCallback('MouseWheelMoved')
            obj.frame.setCallback('WindowClosing',@obj.WindowClosing);
            
        end
        
        function InitFcn(obj,d,gl,pos,col,idx)
            if isempty(idx), drawMode = 'GL_POINTS'; else, drawMode = 'GL_TRIANGLES'; end
            obj.points = glElement(gl,{pos',col'},'pointcloud',obj.shaders,gl.(drawMode),gl.GL_STATIC_DRAW,[gl.GL_FALSE gl.GL_TRUE]);
            
            if ~isempty(idx)
                obj.points.SetIndex(gl,idx');
            end
            
            obj.points.uni.Mat4.model = eye(4,'single');

            r = max(pos) - min(pos);
            obj.cam(6) = -max(r)*2;

            origin_pos = single([0 0 0 ; 1 0 0 ; 0 0 0 ; 0 1 0 ; 0 0 0 ; 0 0 1]');
            origin_col = single([1 0 0 ; 1 0 0 ; 0 1 0 ; 0 1 0 ; 0 0 1 ; 0 0 1]');
            obj.origin = glElement(gl,{origin_pos,origin_col},'pointcloud',obj.shaders,gl.GL_LINES);
            obj.origin.uni.Mat4.model = eye(4,'single');
            
            quadVert = single([-1 -1 0 0; -1 1 0 1; 1 -1 1 0; 1 1 1 1]');
            obj.screen = glElement(gl,quadVert,'screen',obj.shaders,gl.GL_TRIANGLE_STRIP);
            obj.screen.AddTexture(gl,0,gl.GL_TEXTURE_2D,[],[],gl.GL_LINEAR,gl.GL_LINEAR);
            obj.shaders.SetInt1(gl,'screen','colorTex',0);
            obj.screen.AddTexture(gl,1,gl.GL_TEXTURE_2D,[],[],gl.GL_LINEAR,gl.GL_LINEAR);
            obj.shaders.SetInt1(gl,'screen','infoTex',1);
            
            obj.clearFlag = glFlags(gl,'GL_COLOR_BUFFER_BIT','GL_DEPTH_BUFFER_BIT');
            
            gl.glClearColor(0,0,0,0);
            
            obj.ResizeFcn(d,gl);
            
            obj.screen.SetFramebuffer(gl,gl.GL_DEPTH_ATTACHMENT);
        end
        
        function UpdateFcn(obj,d,gl)

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

            if obj.click.button
                obj.origin.Draw(gl);
            end
            obj.screen.UseFramebuffer(gl);

            gl.glEnable(gl.GL_DEPTH_TEST);

            obj.points.Draw(gl);
            
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER,0);
            gl.glDisable(gl.GL_DEPTH_TEST);
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            obj.screen.Draw(gl);
            
            d.swapBuffers;
        end
        
        function ResizeFcn(obj,d,gl)
            sz = [obj.gc.getWidth,obj.gc.getHeight];
            obj.figSize = sz;
            
            obj.screen.EditTex(gl,0,{0,gl.GL_RGB,sz(1),sz(2),0,gl.GL_RGB,gl.GL_UNSIGNED_BYTE,[]});
            obj.screen.EditTex(gl,1,{0,gl.GL_RGBA32F,sz(1),sz(2),0,gl.GL_RGBA,gl.GL_FLOAT,[]});
            obj.screen.EditRenderbuffer(gl,gl.GL_DEPTH_COMPONENT32F,sz);
            
            gl.glViewport(0,0,sz(1),sz(2));
            
            obj.shaders.SetVec2(gl,'screen','scrSz',single(sz));
        end
        
        function MousePressed(obj,src,evt)
            obj.click.button = evt.getButton;
            c = [evt.getX evt.getY];
            obj.click.coords = c;
            p = obj.glFcn(@obj.glGetPoint,c);
            if evt.getModifiers == 18 && ~isempty(p) % ctrl pressed
                fprintf('Point coords: %.3f, %.3f, %.3f\n',double(p)+obj.pos0);
            end
            obj.setFocus(p);
            obj.click.cam = obj.cam;
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
        
        function setFocus(obj,worldCoord)
            if isempty(worldCoord), return, end
            M =  MTrans3D(obj.cam(4:6)) * MRot3D(obj.cam(1:3),1,[1 3]);
            camTranslate = M * [worldCoord-obj.cam(7:9) 1]';
            obj.cam(4:6) = camTranslate(1:3);
            obj.cam(7:9) = worldCoord;
        end
        
        function MouseDragged(obj,src,evt)
            dcoords = [evt.getX evt.getY] - obj.click.coords;
            switch obj.click.button
                case 1
                    % rotation 0.2 deg/pixel
                    obj.cam([3 1]) = obj.click.cam([3 1])+dcoords/5;
                case 3
                    % translate
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
        
        function WindowClosing(obj,src,evt)
            obj.glStop = 1;
        end
        
    end
end

function c = UniformColor(c,n)
    if size(c,2) == 1
        % gray tones
        c = repmat(c,1,3);
    end
    % color
    if ~isinteger(c)
        c = uint8(c.*255);
    end

    if ~isa(c,'uint8')
        c = uint8(single(c)./single(c(1)+inf).*255);
    end

    if size(c,1) == 1
        c = repmat(c,n,1);
    end
end


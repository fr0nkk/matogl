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
    % Left click: rotate
    % Right click: translate
    % scroll wheel: zoom
    % ctrl + left click: display clicked coords in console
    %   *clicked coords are not 100% accurate since they are recalculated
    %   from the inverse projection.
    % ctrl + middle click: zoom
    % ctrl + right click: adjust EDL strength
    
    properties
        figSize
        pos0 % mean of point locations
        
        MView single
        MProj single
        
        shaders

        points
        axe
        screen
        
        % camOrigin, camRotation, camTranslation, focalLength, EDL Strength
        cam = struct('O',[0 0 0]','R',[-45 0 -45]','T',[0 0 -1]','F',1,'E',0.2);
        click
        
        clearFlag
    end
    
    methods
        function obj = glViewer3D(pos,varargin)
            if nargin < 1
                % test example - 160k points, 318k triangles
                [X,Y,Z] = peaks(400);
                pos = [X(:) Y(:) Z(:)];
                clear X Y Z
                T = delaunay(pos(:,1:2));
                varargin{2} = T-1;
            end
            p = inputParser;
            p.addOptional('col',[]);
            p.addOptional('idx',[]);
            p.addParameter('edl',[]);
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
            
            obj.shaders = glShaders(fullfile(fileparts(mfilename('fullpath')),'shaders'));
            obj.Init(jFrame('GL 3D Viewer'),'GL3',0,pos,col,p.Results.idx,p.Results.edl);
            
            obj.setMethodCallback('MousePressed')
            obj.setMethodCallback('MouseReleased')
            obj.setMethodCallback('MouseDragged')
            obj.setMethodCallback('MouseWheelMoved')
            obj.frame.setCallback('WindowClosing',@obj.WindowClosing);
            
        end
        
        function InitFcn(obj,d,gl,pos,col,idx,edl)

            if isempty(idx)
                primitive = gl.GL_POINTS;
            else
                primitive = gl.GL_TRIANGLES;
            end

            obj.points = glElement(gl,{pos',col'},'pointcloud',obj.shaders,primitive,gl.GL_STATIC_DRAW,[gl.GL_FALSE gl.GL_TRUE]);
            
            if ~isempty(idx)
                obj.points.SetIndex(gl,idx');
            end
            
            obj.points.uni.Mat4.model = eye(4,'single');

            camDist = max(max(pos,[],1) - min(pos,[],1));
            if camDist > 0
                obj.cam.T(3) = -camDist*2;
            end

            if ~isempty(edl)
                obj.cam.E = edl;
            end

            obj.click.button = 0;
            obj.click.coords = [0 0];
            obj.click.cam = obj.cam;

            axe_pos = single([0 0 0 ; 1 0 0 ; 0 0 0 ; 0 1 0 ; 0 0 0 ; 0 0 1]');
            axe_col = single([1 0 0 ; 1 0 0 ; 0 1 0 ; 0 1 0 ; 0 0 1 ; 0 0 1]');
            obj.axe = glElement(gl,{axe_pos,axe_col},'pointcloud',obj.shaders,gl.GL_LINES);
            obj.axe.uni.Mat4.model = eye(4,'single');
            obj.axe.show = 0;
            
            quadVert = single([-1 -1 0 0; -1 1 0 1; 1 -1 1 0; 1 1 1 1]');
            obj.screen = glElement(gl,quadVert,'screen',obj.shaders,gl.GL_TRIANGLE_STRIP);
            obj.screen.AddTexture(gl,0,gl.GL_TEXTURE_2D,[],[],gl.GL_LINEAR,gl.GL_LINEAR);
            obj.shaders.SetInt1(gl,'screen','colorTex',0);
            obj.shaders.SetFloat1(gl,'screen','edlStrength',single(obj.cam.E));
            
            obj.clearFlag = glFlags(gl,'GL_COLOR_BUFFER_BIT','GL_DEPTH_BUFFER_BIT');
            
            gl.glClearColor(0,0,0,0);
            
            obj.ResizeFcn(d,gl);
            
            obj.screen.SetFramebuffer(gl,gl.GL_DEPTH_ATTACHMENT);
        end
        
        function UpdateFcn(obj,d,gl)

            % render to texture
            obj.screen.UseFramebuffer(gl);

            gl.glEnable(gl.GL_DEPTH_TEST);
            gl.glClear(obj.clearFlag);
            
            camDist = -obj.cam.T(3);
            near = clamp(camDist/10,1e-3,1);
            far = clamp(camDist*10,100,1e6);
            
            s = obj.figSize;
            obj.MProj = MProj3D('P',[[s/mean(s) obj.cam.F].*near far]);
            obj.shaders.SetMat4(gl,'pointcloud','projection',obj.MProj);
            
            obj.MView = MTrans3D(obj.cam.T) * MRot3D(obj.cam.R,1,[1 3]) * MTrans3D(-obj.cam.O);
            obj.shaders.SetMat4(gl,'pointcloud','view',obj.MView);
            
            obj.axe.Draw(gl);
            obj.points.Draw(gl);

            % render to screen
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER,0);

            gl.glDisable(gl.GL_DEPTH_TEST);
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            obj.screen.Draw(gl);
            
            d.swapBuffers;
        end
        
        function ResizeFcn(obj,~,gl)
            sz = [obj.gc.getWidth,obj.gc.getHeight];
            obj.figSize = sz;
            
            obj.screen.EditTex(gl,0,{0,gl.GL_RGBA32F,sz(1),sz(2),0,gl.GL_RGBA,gl.GL_FLOAT,[]});
            obj.screen.EditRenderbuffer(gl,gl.GL_DEPTH_COMPONENT32F,sz);
            
            gl.glViewport(0,0,sz(1),sz(2));
            
            obj.shaders.SetVec2(gl,'screen','scrSz',single(sz));
        end
        
        function MousePressed(obj,~,evt)
            obj.click.button = evt.getButton;
            c = getEvtXY(evt);
            obj.click.coords = c;
            p = obj.glFcn(@obj.glGetPoint,c);

            if bitand(evt.CTRL_MASK,evt.getModifiers) && ~isempty(p) % ctrl pressed
                fprintf('Point coords: %.3f, %.3f, %.3f\n',double(p)+obj.pos0');
            end
            obj.setFocus(p);
            obj.click.cam = obj.cam;
            obj.axe.show = 1;
            obj.Update
        end
        
        function MouseReleased(obj,~,~)
            obj.click.button = 0;
            obj.axe.show = 0;
            obj.Update;
        end
        
        function p = glGetPoint(obj,~,gl,c)
            obj.screen.UseFramebuffer(gl);
            gl.glReadBuffer(gl.GL_NONE);
            
            r = 2; % click radius (square box) px
            w = 2*r+1; % square side length px
            
            b = javabuffer(zeros(w*w,1,'single'));
            
            s = obj.figSize';
            c(2) = s(2) - c(2);
            
            gl.glReadPixels(c(1)-r,c(2)-r,w,w,gl.GL_DEPTH_COMPONENT,gl.GL_FLOAT,b);
            depth = reshape(b.array,w,w);
            
            p = [];
            n = depth == 1;
            if all(n,'all'), return, end % no valid points in click box
            depth(n) = nan;
            depth = rot90(depth);
            
            [~,k] = min(depth(:));
            [y,x] = ind2sub([w w],k);
            
            % normalized device coordinates
            NDC = [(c+[x-r-0.5 ; r-y+1.5])./s ; depth(k) ; 1].*2-1;
            
            % world coordinates
            WC = obj.MProj * obj.MView \ NDC;
            WC = WC(1:3)./WC(4);
            
            if ~any(isnan(WC))
                obj.axe.uni.Mat4.model = MTrans3D(WC);
                p = WC;
            end
        end
        
        function setFocus(obj,worldCoord)
            if isempty(worldCoord), return, end
            M =  MTrans3D(obj.cam.T) * MRot3D(obj.cam.R,1,[1 3]);
            camTranslate = M * [worldCoord-obj.cam.O ; 1];
            obj.cam.T = camTranslate(1:3);
            obj.cam.O = worldCoord;
        end

        function SetEDL(obj,edl,updateFlag)
            if nargin < 3, updateFlag = 1; end
            [~,gl,temp] = obj.getContext; %#ok<ASGLU> temp is onCleanup()
            obj.cam.E = edl;
            obj.shaders.SetFloat1(gl,'screen','edlStrength',single(edl));
            if updateFlag
                obj.Update;
            end
        end
        
        function MouseDragged(obj,~,evt)
            dxy = getEvtXY(evt) - obj.click.coords;
            ctrlPressed = bitand(evt.CTRL_MASK,evt.getModifiers);
            switch obj.click.button
                case 1
                    % left click
                    % rotation: 0.2 deg/pixel
                    obj.cam.R([3 1]) = obj.click.cam.R([3 1])+dxy*0.2;
                case 2
                    % middle click
                    if ctrlPressed
                        % focal length: half or double per 500 px
                        s = 2^(dxy(2)./500);
                        obj.cam.F = obj.click.cam.F * s;
                    else
                        % zoom: half or double camDistance per 100 px
                        s = 2^(dxy(2)./100);
                        obj.cam.T = obj.click.cam.T .* s;
                    end
                case 3
                    % right click
                    if ctrlPressed
                        % EDL: half or double camDistance per 100 px
                        s = obj.click.cam.E * 2^(dxy(2)./100);
                        obj.SetEDL(s,0);
                    else
                        % translate 1:1 (clicked point follows mouse)
                        c = obj.click.cam;
                        dxy = dxy.*[1 -1]';
                        obj.cam.T([1 2]) = c.T([1 2])+dxy./mean(obj.figSize).*-c.T(3)./c.F;
                    end
                otherwise
                    return
            end
            obj.Update;
        end
        
        function MouseWheelMoved(obj,~,evt)
            s = evt.getUnitsToScroll / 40;
            p = obj.glFcn(@obj.glGetPoint,getEvtXY(evt));
            obj.setFocus(p);
            obj.cam.T = obj.cam.T .* (1+s);
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


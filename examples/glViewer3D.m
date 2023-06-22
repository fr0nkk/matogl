classdef glViewer3D < glmu.GLController
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
            

            frame = JFrame('glViewer3D',[600 450]);
            canvas = frame.add(GLCanvas('GL3',0,obj));
            canvas.Init(pos,col,p.Results.idx,p.Results.edl);
            
            canvas.setCallback('MousePressed',@obj.MousePressed);
            canvas.setCallback('MouseReleased',@obj.MouseReleased);
            canvas.setCallback('MouseDragged',@obj.MouseDragged);
            canvas.setCallback('MouseWheelMoved',@obj.MouseWheelMoved);
        end
        
        function InitFcn(obj,gl,pos,col,idx,edl)

            obj.ptcloudProgram = example_prog('pointcloud');
            u = obj.ptcloudProgram.uniforms;
            obj.cam = glmu.Camera3D(u.projection,u.view);
            buf = {pos',col'};
            norm = [false true];

            if isempty(idx)
                obj.points = glmu.drawable.Array(obj.ptcloudProgram,gl.GL_POINTS,buf,norm);
            else
                obj.points = glmu.drawable.Element(obj.ptcloudProgram,gl.GL_TRIANGLES,idx',buf,norm);
            end

            obj.points.uni.model = eye(4);

            camDist = double(max(max(pos,[],1) - min(pos,[],1)));
            if camDist > 0
                obj.cam.viewParams.T(3) = -camDist*2;
            end

            axe_pos = single([0 0 0 ; 1 0 0 ; 0 0 0 ; 0 1 0 ; 0 0 0 ; 0 0 1]');
            axe_col = single([1 0 0 ; 1 0 0 ; 0 1 0 ; 0 1 0 ; 0 0 1 ; 0 0 1]');

            obj.axe = glmu.drawable.Array(obj.ptcloudProgram,gl.GL_LINES,{axe_pos,axe_col});

            obj.axe.uni.model = eye(4);
            obj.axe.show = 0;
            
            quadVert = single([-1 -1 0 0; -1 1 0 1; 1 -1 1 0; 1 1 1 1]');
            obj.screen = glmu.drawable.Array(example_prog('screen'),gl.GL_TRIANGLE_STRIP,quadVert);

            T = glmu.Texture(0,gl.GL_TEXTURE_2D);

            obj.screen.uni.colorTex = T;

            obj.screen.program.uniforms.edlStrength.Set(edl);
            
            obj.clearFlag = glmu.BitFlags('GL_COLOR_BUFFER_BIT','GL_DEPTH_BUFFER_BIT');
            
            gl.glClearColor(0,0,0,0);
            gl.glReadBuffer(gl.GL_FRONT);
            
            renderbuffer = glmu.Renderbuffer(gl.GL_DEPTH_COMPONENT32F);
            renderbuffer.AddTexture(T,gl.GL_FLOAT,gl.GL_RGBA,gl.GL_RGBA32F);
            obj.framebuffer = glmu.Framebuffer(gl.GL_FRAMEBUFFER,renderbuffer,gl.GL_DEPTH_ATTACHMENT);
        end
        
        function UpdateFcn(obj,gl)
            % render to texture
%             tic
            obj.framebuffer.Bind;
            
            gl.glEnable(gl.GL_DEPTH_TEST);
            gl.glClear(obj.clearFlag);
            
            camDist = -obj.cam.viewParams.T(3);
            near = clamp(camDist/10,1e-3,1);
            far = clamp(camDist*10,100,1e6);
            obj.cam.SetNearFar(near,far);

            obj.cam.Update;
            obj.axe.Draw;
            obj.points.Draw;

            % render to screen
            obj.framebuffer.Release;

            gl.glDisable(gl.GL_DEPTH_TEST);
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            obj.screen.Draw;
%             1/toc
        end
        
        function ResizeFcn(obj,gl,sz)
            obj.figSize = sz;
            obj.cam.Resize(sz);
            obj.framebuffer.Resize(sz);
            
            gl.glViewport(0,0,sz(1),sz(2));
            
            obj.screen.program.uniforms.scrSz.Set(sz);
        end
        
        function MousePressed(obj,~,evt)
            c = getEvtXY(evt);
            p = obj.glGetPoint(c);

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
            [gl,temp] = obj.canvas.getContext;
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER,0);
            w = obj.canvas.java.getWidth;
            h = obj.canvas.java.getHeight;
            
            gl.glPixelStorei(gl.GL_PACK_ALIGNMENT,1);
            b = javabuffer(zeros(3,w,h,'uint8'));
            gl.glReadPixels(0,0,w,h,gl.GL_RGB, gl.GL_UNSIGNED_BYTE, b.p);
            img = b.array;
            img = permute(img,[2 3 1]);
            img = rot90(img);

            if nargout == 0
                figure('Name','glViewer3D.Snapshot','NumberTitle','off');
                imshow(img);
                clear img
            end
        end
        
        function WC = glGetPoint(obj,c)
            [gl,temp] = obj.canvas.getContext;
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
            [gl,temp] = obj.canvas.getContext; %#ok<ASGLU> temp is onCleanup()
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
            p = obj.glGetPoint(getEvtXY(evt));
            obj.cam.SetRotationOrigin(p);
            obj.cam.MouseWheelMoved(evt);
            obj.Update;
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


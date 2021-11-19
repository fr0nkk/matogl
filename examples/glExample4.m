classdef glExample4 < glCanvas
    
    properties
        cam single = [-45 0 -135 0 0 -3]; % [rotation translation]
        click struct = struct('ij',[0 0],'cam',[0 0 0 0 0 0],'button',0);
        sz single = [600 450];
        
        % perspective params {verticalFov near far}
        pParams = {45 0.1 200};

        shaders
        
        origin
        colorcube
        img2D
        img3D
        text
    end
    
    methods
        function obj = glExample4()
            % create java frame
            frame = jFrame('Utility Examples',obj.sz);
            
            % Initialize opengl in frame using GL4 profile and multisample 4
            obj.Init(frame,'GL3',4);
            
            % activate callbacks
            obj.setMethodCallback('MousePressed');
            obj.setMethodCallback('MouseDragged');
            obj.setMethodCallback('MouseWheelMoved');
        end
        
        function InitFcn(obj,d,gl)
            % init shaders
            obj.shaders = glShaders(fullfile(fileparts(mfilename('fullpath')),'shaders'));

            % make axes
            xyz = single([0 0 0 ; 1 0 0 ; 0 0 0 ; 0 1 0 ; 0 0 0 ; 0 0 1]');
            color = single([1 0 0 ; 1 0 0 ; 0 1 0 ; 0 1 0 ; 0 0 1 ; 0 0 1]');
            obj.origin = glElement(gl,{xyz,color},'example1',obj.shaders,gl.GL_LINES);
            obj.origin.uni.Mat4.model = eye(4,'single');
            
            % make color cube
            N = 32;
            w = single(linspace(0,1,N));
            [x,y,z] = ndgrid(w,w,w);
            xyz = [x(:) y(:) z(:)] + rand(N^3,3)./N; % remove the +rand for some funky patterns
            col = xyz;
            obj.colorcube = glElement(gl,{xyz',col'},'example1',obj.shaders,gl.GL_POINTS);
            M = MTrans3D([0.1 0.1 0.3]) * MScale3D(0.25);
            obj.colorcube.uni.Mat4.model = single(M);
            
            % make ortho image
            im = imread('ngc6543a.jpg');
            ijNorm = single([0 0;1 0;0 1;1 1]');
            pos = ijNorm./1.5+0.2; pos(3,:) = 0;
            obj.img2D = glElement(gl,{pos,ijNorm},'example2',obj.shaders,gl.GL_TRIANGLE_STRIP);
            obj.img2D.AddTexture(gl,0,gl.GL_TEXTURE_2D,im,gl.GL_RGB);
            obj.shaders.SetInt1(gl,'example2','texture1',0);
            
            %make perspective image
            obj.shaders.Init(gl,'example2','image2'); % instance an other example2 shader with different uniform values
            obj.img3D = glElement(gl,{pos,ijNorm},'image2',obj.shaders,gl.GL_TRIANGLE_STRIP);
            obj.img3D.AddTexture(gl,1,gl.GL_TEXTURE_2D,'peppers.png',gl.GL_RGB); % path to image is also valid
            obj.shaders.SetInt1(gl,'image2','texture1',1);
            
            % init text renderer
            obj.text = glText(gl,obj.shaders);
            obj.text.SetOrtho(0,1);
            obj.text.SetPerspective(obj.pParams{:});
            
            gl.glEnable(gl.GL_DEPTH_TEST);
            gl.glClearColor(0,0,0,0);
            
        end
        
        function UpdateFcn(obj,d,gl)
            % d is the GLDrawable
            % gl is the GL object
            
            % clear color and depth
            gl.glClear(glFlags(gl,'GL_COLOR_BUFFER_BIT','GL_DEPTH_BUFFER_BIT'));
            
            % make the view transform matrix and set it in the shader
            m = MTrans3D(obj.cam(4:6)) * MRot3D(obj.cam(1:3),1,[1 3]);
            
            obj.shaders.SetMat4(gl,'example1','view',m);
            obj.shaders.SetMat4(gl,'image2','view',m);
            
            obj.img2D.Draw(gl);
            obj.img3D.Draw(gl);
            obj.origin.Draw(gl);
            obj.colorcube.Draw(gl);
            
            transfText =  MTrans3D([0.9 0 0.8]) * MRot3D([90 0 180],1);
            obj.text.Render3D(gl,'Arial','perspective',0.1,[1 1 0 1],m * transfText);
            
            transfText =  MTrans3D([0.9 0 0.5]) * MRot3D(-obj.cam(1:3),1);
            obj.text.Render3D(gl,'Arial','normal',0.1,[1 1 0 1],m * transfText);
            
            transfText =  MTrans3D(single([20 20 0]));
            obj.text.Render2D(gl,'Arial','ortho',18,[1 1 0 1],transfText);
            
            % update display
            d.swapBuffers;
        end
        
        function MousePressed(obj,~,evt)
            % record the screen coordinates, camera and button when click happened
            obj.click.ij = [evt.getX evt.getY];
            obj.click.cam = obj.cam;
            obj.click.button = evt.getButton;
        end
        
        function MouseDragged(obj,~,evt)
            % delta from when the mouse was pressed
            dij = [evt.getX evt.getY] - obj.click.ij;
            c = obj.click.cam;
            switch obj.click.button
                case 1
                    % left click: rotate
                    obj.cam([3 1]) = c([3 1])+dij/5;
                case 3
                    % right click: pan
                    obj.cam([4 5]) = c([4 5])+dij.*[-1 1]./mean(obj.sz).*c(6);
                otherwise
                    return
            end
            obj.Update;
        end
        
        function MouseWheelMoved(obj,~,evt)
            % scroll wheel: zoom
            z = evt.getUnitsToScroll / 50;
            obj.cam(4:6) = obj.cam(4:6)+obj.cam(4:6).*z;
            obj.Update;
        end
        
        function ResizeFcn(obj,d,gl)
            % new canvas size
            newSz = [obj.gc.getWidth obj.gc.getHeight];
            obj.sz = newSz;
            
            % keep the gl view fullscreen
            gl.glViewport(0,0,newSz(1),newSz(2));
            
            % Update the projection matrix
            m = MProj3D('F',[newSz(1)/newSz(2) obj.pParams{:}],1);
            obj.shaders.SetMat4(gl,'example1','projection',single(m));
            obj.shaders.SetMat4(gl,'image2','projection',single(m));
            
            obj.text.Reshape(newSz); 
        end
        
        
    end
end


classdef glExample5 < glCanvas
    
    properties
        cam single = [-45 0 -135 0 0 -3]; % [rotation translation]
        click struct = struct('ij',[0 0],'cam',[0 0 0 0 0 0],'button',0);
        sz single = [600 450];

        origin
        colorcube
        img2D
        img3D
        text2D
        text3D
    end
    
    methods
        function obj = glExample5()
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
            glmu.SetResourcesPath(fileparts(mfilename('fullpath')));

            % make axes
            xyz = single([0 0 0 ; 1 0 0 ; 0 0 0 ; 0 1 0 ; 0 0 0 ; 0 0 1]');
            color = single([1 0 0 ; 1 0 0 ; 0 1 0 ; 0 1 0 ; 0 0 1 ; 0 0 1]');
            
            obj.origin = glmu.DrawableArray({xyz,color},'example1',gl.GL_LINES);
            obj.origin.uni.model = eye(4);
            
            % make color cube
            N = 32;
            w = single(linspace(0,1,N));
            [x,y,z] = ndgrid(w,w,w);
            xyz = [x(:) y(:) z(:)] + rand(N^3,3)./N; % remove the +rand for some funky patterns
            col = xyz;
            obj.colorcube = glmu.DrawableArray({xyz',col'},'example1','GL_POINTS'); % all GL constant args can also be set as text
            obj.colorcube.uni.model = MTrans3D([0.1 0.1 0.3]) * MScale3D(0.25);
            
            % make ortho image
            im = imread('ngc6543a.jpg');
            ijNorm = single([0 0;1 0;0 1;1 1]');
            pos = ijNorm./1.5+0.2; pos(3,:) = 0;
            obj.img2D = glmu.DrawableArray({pos,ijNorm},'example2',gl.GL_TRIANGLE_STRIP);
            T = glmu.Texture(0,gl.GL_TEXTURE_2D,im,gl.GL_RGB,2);
            obj.img2D.AddTexture('texture1',T);
            
            % make perspective image
            obj.img3D = glmu.DrawableArray({pos,ijNorm},'example2#2',gl.GL_TRIANGLE_STRIP); % #2 uses the 2nd instance of the same program
            T = glmu.Texture(1,gl.GL_TEXTURE_2D,'peppers.png',gl.GL_RGB,2); % texture data can also be a path to an image
            obj.img3D.AddTexture('texture1',T);

            model = MTrans3D([0.9 0 0.8]) * MRot3D([90 0 180],1);
            obj.text3D = glmu.Text('arial','Perspective',0.1,[1 1 0 1],model);
            obj.text3D.Add('Normal',0.1,[1 1 0 1]);

            obj.text2D = glmu.Text('arial','Ortho',18,[1 1 0 1],MTrans3D([-150 -100 0]));
            gl.glEnable(gl.GL_DEPTH_TEST);
            gl.glClearColor(0,0,0,0);
            
        end
        
        function UpdateFcn(obj,d,gl)
            % d is the GLDrawable
            % gl is the GL object
            
            % clear color and depth
            gl.glClear(glmu.BitFlags('GL_COLOR_BUFFER_BIT','GL_DEPTH_BUFFER_BIT'));
            
            % make the view transform matrix and set it in the shader
            m = MTrans3D(obj.cam(4:6)) * MRot3D(obj.cam(1:3),1,[1 3]);
            
            obj.origin.uni.view = m;
            obj.img3D.uni.view = m;
            obj.text3D.view = m;
            obj.text3D.model{2} = MTrans3D([0.9 0 0.5]) * MRot3D(-obj.cam(1:3),1);

            obj.img2D.Draw;
            obj.img3D.Draw;
            obj.origin.Draw;
            obj.colorcube.Draw;
            
            obj.text3D.Draw;
            obj.text2D.Draw;
            
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
            newSz = [obj.java.getWidth obj.java.getHeight];
            obj.sz = newSz;
            
            % keep the gl view fullscreen
            gl.glViewport(0,0,newSz(1),newSz(2));
            
            % Update the projection matrix
            m = MProj3D('F',[obj.sz(1)/obj.sz(2) 45 0.1 200],1);

            obj.origin.program.uniforms.projection.Set(m);
            obj.img3D.program.uniforms.projection.Set(m);
            obj.text3D.projection = m;
            obj.text2D.projection = MProj3D('O',[obj.sz -1 1]);
        end
        
        
    end
end


classdef glExample5 < glmu.GLController
    
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
        text3DNorm
    end
    
    methods
        function obj = glExample5()

            frame = JFrame('Utility Examples',[600 450]);
            canvas = frame.add(GLCanvas('GL3',4,obj));
            canvas.Init;
            
            % activate callbacks
            canvas.setCallback('MousePressed',@obj.MousePressed);
            canvas.setCallback('MouseDragged',@obj.MouseDragged);
            canvas.setCallback('MouseWheelMoved',@obj.MouseWheelMoved);
        end
        
        function InitFcn(obj,gl)
            % make axes
            xyz = single([0 0 0 ; 1 0 0 ; 0 0 0 ; 0 1 0 ; 0 0 0 ; 0 0 1]');
            color = single([1 0 0 ; 1 0 0 ; 0 1 0 ; 0 1 0 ; 0 0 1 ; 0 0 1]');

            prog1 = example_prog('example1');
            
            obj.origin = glmu.drawable.Array(prog1,gl.GL_LINES,{xyz,color});
            obj.origin.uni.model = eye(4);

            % make color cube
            N = 32;
            w = single(linspace(0,1,N));
            [x,y,z] = ndgrid(w,w,w);
            xyz = [x(:) y(:) z(:)] + rand(N^3,3)./N; % remove the +rand for some funky patterns
            col = xyz;
            obj.colorcube = glmu.drawable.Array(prog1,'GL_POINTS',{xyz',col'}); % all GL constant args can also be set as text
            obj.colorcube.uni.model = MTrans3D([0.1 0.1 0.3]) * MScale3D(0.25);
            
            % make ortho image
            prog2 = example_prog('example2');
            im = imread('ngc6543a.jpg');
            ijNorm = single([0 0;1 0;0 1;1 1]');
            pos = ijNorm./1.5+0.2; pos(3,:) = 0;
            obj.img2D = glmu.drawable.Array(prog2,gl.GL_TRIANGLE_STRIP,{pos,ijNorm});
            tex1 = glmu.Texture(0,gl.GL_TEXTURE_2D,im,gl.GL_RGB,2);
            obj.img2D.uni.mytexture = tex1;
            obj.img2D.uni.view = eye(4);
            obj.img2D.uni.model = eye(4);
            obj.img2D.uni.projection = eye(4);

            % make perspective image
            obj.img3D = glmu.drawable.Array(prog2,gl.GL_TRIANGLE_STRIP,{pos,ijNorm});
            tex2 = glmu.Texture(1,gl.GL_TEXTURE_2D,'peppers.png',gl.GL_RGB,2); % texture data can also be a path to an image
            obj.img3D.uni.mytexture = tex2;
            obj.img3D.uni.model = eye(4);
            
            % make perspective text
            model = MTrans3D([0.9 0 0.8]) * MRot3D([90 0 180],1);
            obj.text3D = glmu.drawable.Text('Perspective',0.1,[1 1 0 1],eye(4),model,eye(4),'arial');
            
            % make normal 3D text
            obj.text3DNorm = glmu.drawable.Text('Normal',0.1,[1 1 0 1]);
            
            % make 2D text
            obj.text2D = glmu.drawable.Text('Ortho',18,[1 1 0 1],eye(4),MTrans3D([-150 -100 0]));


            gl.glEnable(gl.GL_DEPTH_TEST);
            gl.glClearColor(0,0,0,0);
            
        end
        
        function UpdateFcn(obj,gl)
            % d is the GLDrawable
            % gl is the GL object
            
            % clear color and depth
            gl.glClear(glmu.BitFlags('GL_COLOR_BUFFER_BIT','GL_DEPTH_BUFFER_BIT'));
            
            % make the view transform matrix
            m = MTrans3D(obj.cam(4:6)) * MRot3D(obj.cam(1:3),1,[1 3]);
            
            obj.origin.uni.view = m;
            obj.origin.Draw;

            obj.colorcube.uni.view = m;
            obj.colorcube.Draw;

            obj.img2D.Draw;

            obj.img3D.uni.view = m;
            obj.img3D.Draw;

            obj.text3D.view = m;
            obj.text3D.Draw;

            % keep the normal text facing the camera
            obj.text3DNorm.model = MTrans3D([0.9 0 0.5]) * MRot3D(-obj.cam(1:3),1);
            obj.text3DNorm.view = m;
            obj.text3DNorm.Draw;

            obj.text2D.Draw;
            
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
        
        function ResizeFcn(obj,gl,sz)
            % keep the gl view fullscreen
            gl.glViewport(0,0,sz(1),sz(2));
            
            % Update the projection matrix
            m = MProj3D('F',[sz(1)/sz(2) 45 0.1 200],1);
            obj.origin.uni.projection = m;
            obj.colorcube.uni.projection = m;
            obj.img3D.uni.projection = m;
            obj.text3D.proj = m;
            obj.text3DNorm.proj = m;

            obj.text2D.proj = MProj3D('O',[sz -1 1]);
        end
        
    end
end


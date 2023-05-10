classdef glExample1 < GLController
    % Some "Hello World!" OpenGL example using fixed function pipeline
    
    properties
        
    end
    
    methods
        function obj = glExample1()
            frame = JFrame('HelloTriangle 1',[600 450]);
            canvas = frame.add(GLCanvas('GL2',0,obj));
            canvas.Init;
        end
        
        function InitFcn(obj,gl)
            gl.glClearColor(0,0,0,1);
        end

        function UpdateFcn(obj,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            gl.glBegin(gl.GL_TRIANGLES);
            gl.glColor3f( 1, 0, 0 );
            gl.glVertex2f( -0.8, -0.8 );
            gl.glColor3f( 0, 1, 0 );
            gl.glVertex2f( 0.8, -0.8 );
            gl.glColor3f( 0, 0, 1 );
            gl.glVertex2f( 0, 0.9 );
            gl.glEnd();
        end

    end
end


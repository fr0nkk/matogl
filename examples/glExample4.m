classdef glExample4 < glCanvas
    % Same as glExample3, but using glmu.DrawableArray to abstract almost all objects
    
    properties
        myTriangle
    end
    
    methods
        function obj = glExample4()
            frame = jFrame('HelloTriangle 4',[600 450]);
            obj.Init(frame,'GL3');
        end
        
        function InitFcn(obj,d,gl)
            glmu.SetResourcesPath(fileparts(mfilename('fullpath')));

            gl.glClearColor(0,0,0,1);
            
            % data
            vertex = single([-0.8 -0.8 0 ; 0.8 -0.8 0 ; 0 0.9 0]);
            color = single([1 0 0 ; 0 1 0 ; 0 0 1]);
            
            obj.myTriangle = glmu.drawable.Array('example1',gl.GL_TRIANGLES,{vertex',color'});
        end
        
        function UpdateFcn(obj,d,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            
            obj.myTriangle.Draw;
            
            d.swapBuffers;
        end
        
        function ResizeFcn(obj,d,gl)
            gl.glViewport(0,0,obj.java.getWidth,obj.java.getHeight);
        end
    end
end


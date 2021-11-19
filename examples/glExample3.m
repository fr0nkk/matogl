classdef glExample3 < glCanvas
    % Same as glExample2, but using some home made gl utility to
    % abstract all the process of creating and managing buffers, vertex
    % arrays and shaders
    
    properties
        shaders
        triangleElement
    end
    
    methods
        function obj = glExample3()
            frame = jFrame('HelloTriangle 3',[600 450]);
            obj.Init(frame,'GL3');
        end
        
        function InitFcn(obj,d,gl)
            gl.glClearColor(0,0,0,1);
            
            shaderDir = fullfile(fileparts(mfilename('fullpath')),'shaders');
            obj.shaders = glShaders(shaderDir);
            
            % data
            vertex = single([-0.8 -0.8 0 ; 0.8 -0.8 0 ; 0 0.9 0]);
            color = single([1 0 0 ; 0 1 0 ; 0 0 1]);
            
            obj.triangleElement = glElement(gl,{vertex',color'},'example1',obj.shaders,gl.GL_TRIANGLES);
        end
        
        function UpdateFcn(obj,d,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            
            obj.triangleElement.Draw(gl)
            
            % update display
            d.swapBuffers;
        end
        
        function ResizeFcn(obj,d,gl)
            gl.glViewport(0,0,obj.gc.getWidth,obj.gc.getHeight);
        end
    end
end


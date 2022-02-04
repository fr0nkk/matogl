classdef glExample3 < glCanvas
    % Same as glExample2, but using glmu to simplify objects creation and management
    
    properties
        myVertexArray
        myProgram
    end
    
    methods
        function obj = glExample3()
            frame = jFrame('HelloTriangle 3',[600 450]);
            obj.Init(frame,'GL3');
        end
        
        function InitFcn(obj,d,gl)
            gl.glClearColor(0,0,0,1);
            
            % data
            vertex = single([-0.8 -0.8 0 ; 0.8 -0.8 0 ; 0 0.9 0]);
            color = single([1 0 0 ; 0 1 0 ; 0 0 1]);

            B = glmu.Buffer(gl.GL_ARRAY_BUFFER,{vertex',color'});

            obj.myVertexArray = glmu.ArrayPointer(B);
            
            shaderDir = fullfile(fileparts(mfilename('fullpath')),'shaders');

            vertSource = fileread(fullfile(shaderDir,'example1.vert.glsl'));
            vertShader = glmu.Shader(gl.GL_VERTEX_SHADER,vertSource);
            
            fragSource = fileread(fullfile(shaderDir,'example1.frag.glsl'));
            fragShader = glmu.Shader(gl.GL_FRAGMENT_SHADER,fragSource);
            
            obj.myProgram = glmu.Program({vertShader fragShader});
        end
        
        function UpdateFcn(obj,d,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            
            obj.myVertexArray.Bind;
            obj.myProgram.Use;
            gl.glDrawArrays(gl.GL_TRIANGLES,0,3);
            
            d.swapBuffers;
        end
        
        function ResizeFcn(obj,d,gl)
            gl.glViewport(0,0,obj.java.getWidth,obj.java.getHeight);
        end
    end
end


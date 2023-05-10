classdef glExample3 < glmu.GLController
    % Same as glExample2, but using glmu to simplify objects creation and management
    % nos using glmu.GLController instead of GLController
    
    properties
        myVertexArray
        myProgram
    end
    
    methods
        function obj = glExample3()
            frame = JFrame('HelloTriangle 3',[600 450]);
            canvas = frame.add(GLCanvas('GL3',0,obj));
            canvas.Init;
        end
        
        function InitFcn(obj,gl)
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
        
        function UpdateFcn(obj,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            
            obj.myVertexArray.Bind;
            obj.myProgram.Use;
            gl.glDrawArrays(gl.GL_TRIANGLES,0,3);
        end

    end
end


classdef glExample2 < glCanvas
    % Same as glExample1, but using a shader to render.
    
    properties
        prog
        vertexArray
    end
    
    methods
        function obj = glExample2()
            frame = jFrame('HelloTriangle 2',[600 450]);
            obj.Init(frame,'GL3');
        end
        
        function InitFcn(obj,d,gl)
            gl.glClearColor(0,0,0,1);
            
            % data
            vertex = single([-0.8 -0.8 0 ; 0.8 -0.8 0 ; 0 0.9 0]);
            color = single([1 0 0 ; 0 1 0 ; 0 0 1]);
            

            % make vertex buffer
            b = javabuffer(int32(0));
            gl.glGenBuffers(1,b);
            vertexBuffer = b.array;

            % set vertex buffer
            gl.glBindBuffer(gl.GL_ARRAY_BUFFER,vertexBuffer);
            [b,bytesPerValue] = javabuffer(vertex');
            gl.glBufferData(gl.GL_ARRAY_BUFFER,bytesPerValue*b.capacity,b,gl.GL_STATIC_DRAW);
            

            % make color buffer
            b = javabuffer(int32(0));
            gl.glGenBuffers(1,b);
            colorBuffer = b.array;

            % set color buffer
            gl.glBindBuffer(gl.GL_ARRAY_BUFFER,colorBuffer);
            [b,bytesPerValue] = javabuffer(color');
            gl.glBufferData(gl.GL_ARRAY_BUFFER,bytesPerValue*b.capacity,b,gl.GL_STATIC_DRAW);
            

            % make vertex array
            b = javabuffer(int32(0));
            gl.glGenVertexArrays(1,b);
            obj.vertexArray = b.array;
            gl.glBindVertexArray(obj.vertexArray);

            % set vertex buffer pointer
            gl.glBindBuffer(gl.GL_ARRAY_BUFFER,vertexBuffer)
            gl.glVertexAttribPointer(0,3,gl.GL_FLOAT,gl.GL_FALSE,0,0);
            gl.glEnableVertexAttribArray(0);
            
            % set color buffer pointer
            gl.glBindBuffer(gl.GL_ARRAY_BUFFER,colorBuffer)
            gl.glVertexAttribPointer(1,3,gl.GL_FLOAT,gl.GL_FALSE,0,0);
            gl.glEnableVertexAttribArray(1);
            

            % create shader program
            shaderDir = fullfile(fileparts(mfilename('fullpath')),'shaders');
            obj.prog = gl.glCreateProgram();
            
            % compile and attach vertex shader
            vertShader = gl.glCreateShader(gl.GL_VERTEX_SHADER);
            vertSource = fileread(fullfile(shaderDir,'example1.vert.glsl'));
            gl.glShaderSource(vertShader,1,vertSource,[]);
            gl.glCompileShader(vertShader);
            gl.glAttachShader(obj.prog,vertShader);
            
            % compile and attach fragment shader
            fragShader = gl.glCreateShader(gl.GL_FRAGMENT_SHADER);
            fragSource = fileread(fullfile(shaderDir,'example1.frag.glsl'));
            gl.glShaderSource(fragShader,1,fragSource,[]);
            gl.glCompileShader(fragShader);
            gl.glAttachShader(obj.prog,fragShader);
            
            % link program
            gl.glLinkProgram(obj.prog);
            
        end

        function UpdateFcn(obj,d,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            
            % prepare to draw with shader and vertex array
            gl.glUseProgram(obj.prog);
            gl.glBindVertexArray(obj.vertexArray);
            
            % draw
            gl.glDrawArrays(gl.GL_TRIANGLES,0,3);
            
            % update display
            d.swapBuffers;
        end

        function ResizeFcn(obj,d,gl)
            gl.glViewport(0,0,obj.gc.getWidth,obj.gc.getHeight);
        end
    end
end


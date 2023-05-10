classdef glExample4 < glmu.GLController
    % Same as glExample3, but using glmu.DrawableArray to abstract almost all objects
    
    properties
        myTriangle
    end
    
    methods
        function obj = glExample4()
            % can be chained in newer matlab versions:
            JFrame('HelloTriangle 4').add(GLCanvas('GL3',0,obj)).Init;
        end
        
        function InitFcn(obj,gl)
            gl.glClearColor(0,0,0,0);
            
            vertex = single([-0.8 -0.8 0 ; 0.8 -0.8 0 ; 0 0.9 0]);
            color = single([1 0 0 ; 0 1 0 ; 0 0 1]);
            
            thisDir = fileparts(mfilename('fullpath'));
            shaderPath = fullfile(thisDir,'shaders','example1');
            obj.myTriangle = glmu.drawable.Array(shaderPath,gl.GL_TRIANGLES,{vertex',color'});
        end
        
        function UpdateFcn(obj,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            obj.myTriangle.Draw;
        end

    end
end


classdef ShaderState < glmu.internal.ObjectState
    
    properties
        newFcn = @glCreateShader
        shadersPath = ''
    end
    
    methods
        
        function id = New(obj,type)
            id = obj.Create(type);
        end

        function Delete(obj,id)
            
        end

    end
end


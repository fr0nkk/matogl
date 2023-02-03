classdef ShaderState < glmu.internal.ObjectState
    
    properties
        newFcn = @glCreateShader
        delFcn = @glDeleteShader
        shadersPath = ''
    end
    
    methods
        
        function id = New(obj,type)
            id = obj.Create(type);
        end

        function Delete(obj,id)
            obj.Delete1(id);
        end

    end
end


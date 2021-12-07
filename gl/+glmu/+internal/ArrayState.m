classdef ArrayState < glmu.internal.ObjectState
    
    properties
        newFcn = @glGenVertexArrays
    end
    
    methods
        
        function id = New(obj,varargin)
            id = obj.Gen(varargin{:});
        end

        function Bind(obj,id)
            if obj.current == id, return, end
            obj.gl.glBindVertexArray(id);
            obj.current = id;
        end

        function Delete(obj,id)
            
        end

    end
end


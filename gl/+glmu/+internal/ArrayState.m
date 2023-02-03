classdef ArrayState < glmu.internal.ObjectState
    
    properties
        newFcn = @glGenVertexArrays
        delFcn = @glDeleteVertexArrays
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
            obj.DeleteN(id);
        end

    end
end


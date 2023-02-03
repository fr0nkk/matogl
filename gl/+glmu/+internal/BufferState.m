classdef BufferState < glmu.internal.ObjectState
    
    properties
        newFcn = @glGenBuffers
        delFcn = @glDeleteBuffers
    end
    
    methods
        
        function id = New(obj,varargin)
            id = obj.Gen(varargin{:});
        end

        function Bind(obj,target,id)
            i = find(target == obj.targets,1);
            if isempty(i)
                i = numel(obj.targets)+1;
                obj.targets(i) = target;
                obj.current(i) = 0;
            end
            if obj.current(i) == id, return, end
            obj.gl.glBindBuffer(target,id);
            obj.current(i) = id;
        end

        function Delete(obj,id)
            obj.DeleteN(id);
        end

    end
end


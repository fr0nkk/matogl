classdef FramebufferState < glmu.internal.ObjectState
    
    properties
        newFcn = @glGenFramebuffers
        delFcn = @glDeleteFramebuffers
    end
    
    methods
        
        function id = New(obj,varargin)
            id = obj.Gen(varargin{:});
        end

        function Bind(obj,target,id)
            if obj.current == id, return, end
            obj.gl.glBindFramebuffer(target,id);
            obj.current = id;
        end

        function Delete(obj,id)
            obj.DeleteN(id);
        end

    end
end


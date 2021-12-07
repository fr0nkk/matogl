classdef FramebufferState < glmu.internal.ObjectState
    
    properties
        newFcn = @glGenFramebuffers
    end
    
    methods
        
        function id = New(obj,varargin)
            id = obj.Gen(varargin{:});
        end

        function Bind(obj,target,id)
            obj.gl.glBindFramebuffer(target,id);
        end

        function Delete(obj,id)
            
        end

    end
end


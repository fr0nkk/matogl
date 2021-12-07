classdef RenderbufferState < glmu.internal.ObjectState
    
    properties
        newFcn = @glGenRenderbuffers
    end
    
    methods
        
        function id = New(obj,varargin)
            id = obj.Gen(varargin{:});
        end

        function Bind(obj,id)
            obj.gl.glBindRenderbuffer(obj.gl.GL_RENDERBUFFER,id);
        end

        function Delete(obj,id)
            
        end

    end
end


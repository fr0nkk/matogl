classdef RenderbufferState < glmu.internal.ObjectState
    
    properties
        newFcn = @glGenRenderbuffers
        delFcn = @glDeleteRenderbuffers
    end
    
    methods
        
        function id = New(obj,varargin)
            id = obj.Gen(varargin{:});
        end

        function Bind(obj,id)
            if obj.current == id, return, end
            obj.gl.glBindRenderbuffer(obj.gl.GL_RENDERBUFFER,id);
            obj.current = id;
        end

        function Delete(obj,id)
            obj.DeleteN(id);
        end

    end
end


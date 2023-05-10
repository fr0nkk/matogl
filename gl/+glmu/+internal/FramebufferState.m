classdef FramebufferState < glmu.internal.ObjectState
    
    properties
        newFcn = @glGenFramebuffers
        delFcn = @glDeleteFramebuffers

        targetsType
% current = readBuffer drawBuffer
%         currentDraw = 0
%         currentRead = 0
    end
    
    methods
        
        function id = New(obj,varargin)
            id = obj.Gen(varargin{:});
            if isscalar(obj.current), obj.current = int32([0 0]); end
        end

        function Bind(obj,target,id)
            i = obj.getTarget(target);
            if all(obj.current(i) == id), return, end
            
            obj.gl.glBindFramebuffer(target,id);
            obj.current(i) = id;
        end

        function t = getTarget(obj,target)
            if isempty(obj.targetsType)
                T = {'GL_FRAMEBUFFER' 'GL_FRAMEBUFFER' ; 'GL_READ_FRAMEBUFFER' 'GL_DRAW_FRAMEBUFFER'};
                obj.targetsType = cellfun(@obj.Const,T);
            end
            t = any(obj.targetsType == target,1);
        end

        function Delete(obj,id)
            obj.DeleteN(id);
        end

    end
end


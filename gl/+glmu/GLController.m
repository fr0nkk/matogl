classdef GLController < GLController
    
    properties
        state
    end
    
    methods
        function InternalInit(obj,gl,varargin)
            glmu.State(1);
            obj.state = glmu.State;
            obj.InitFcn(gl,varargin{:})
        end

        function InternalUpdate(obj,gl)
            obj.UpdateFcn(gl);
            obj.state.CleanUp;
        end
        
    end
end


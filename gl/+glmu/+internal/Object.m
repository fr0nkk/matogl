classdef Object < glmu.internal.Base
    
    properties
        id
        state
    end
    
    methods
        function obj = Object()
            obj.state = glmu.State(obj.gl);
        end
        
%         function state = get.state(obj)
%             if isempty(obj.state)
%                 obj.state = glmu.States(obj.gl);
%             end
%             state = obj.state;
%         end

    end
end


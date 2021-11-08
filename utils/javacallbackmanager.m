classdef javacallbackmanager < handle
    % helper functions for interfacing with java object callbacks
    % do not forget to rmCallback() before deleting concerned objects or
    % they will stay in memory and 'clear classes' will fail
    properties(Hidden)
        callback_list
    end
    
    properties(Access=private)
        h
    end
    
    methods(Sealed=true)
        
        function obj = javacallbackmanager(javaObj)
            if nargin < 1, return, end
            obj.populateCallbacks(javaObj);
        end
        
        function populateCallbacks(obj,javaObj)
            obj.h = javaObj.handle('CallbackProperties');
            fn = fieldnames(obj.h);
            fn = fn(endsWith(fn,'CallbackData'));
            obj.callback_list = extractBefore(fn,'CallbackData');
        end
        
        function tf = isValidCallback(obj,target,errorFlag)
            assert(ischar(target));
            tf = ismember(target,obj.callback_list);
            if ~tf && errorFlag
                error(['invalid callback: ' target]);
            end
        end
        
        function setCallback(obj,target,fcn)
            obj.isValidCallback(target,1);
            obj.h.([target 'Callback']) = fcn;
        end
        
        function setMethodCallback(obj,target)
            obj.isValidCallback(target,1);
            obj.h.([target 'Callback']) = @(src,evt) obj.(target)(src,evt);
        end
        
        function rmCallback(obj,target)
            if nargin > 1
                obj.isValidCallback(target,1);
                obj.h.([target 'Callback']) = [];
            else
                for i=1:numel(obj.callback_list)
                    obj.h.([obj.callback_list{i} 'Callback']) = [];
                end
            end
        end
        
    end
end


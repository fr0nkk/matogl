classdef javacallbackmanager < handle
% Helper functions for interfacing with java object callbacks.
% Do not forget to rmCallback() before deleting concerned objects or
% they will stay in memory and 'clear classes' will fail.
% Can be set as superclass or as standalone property
% m = javacallbackmanager(javaObj);
%   see m.callback_list for list of possible callbacks
%   if defined as a superclass, use .populateCallbacks(javaObj) in the class initialization
% .setCallback(target,callback)
%   define callback on java event target
%   target must be a member of callback_list
% .setMethodCallback(target)
%   for use when javacallbackmanager is a superclass of class A.
%   When triggered, the class A method named target is called
% .rmCallback(target)
%   remove a previously defined callback
%   if no argument, remove every callbacks

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


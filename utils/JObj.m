classdef JObj < handle
    
    properties
        java
    end

    properties(Abstract,Hidden)
        constructor
    end
    
    methods
        function obj = JObj(varargin)
            obj.java = obj.constructor(varargin{:});
        end

        function v = const(obj,v)
            if isnumeric(v), return, end
            v = obj.java.(upper(v));
        end
    end
end


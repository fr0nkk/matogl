classdef Base < handle
    
    properties(Hidden)
        gl
    end
    
    methods
        function obj = Base()
            obj.gl = glmu.internal.getgl;
            obj.Init;
        end

        function C = Const(obj,C,n)
            if nargin < 3, n=1; end
            if ~isnumeric(C)
                if iscell(C)
                    C = cellfun(@(c) obj.Const(c),C);
                else
                    if islogical(C)
                        tf = [obj.gl.GL_FALSE obj.gl.GL_TRUE];
                        C = tf(C+1);
                    else
                        C = obj.gl.(C);
                    end
                end
            end
            if n>1 && numel(C) == 1, C = repmat(C,n,1); end
        end
    end

    methods(Access=protected)
        function Init(~)
        end
    end

end


classdef ObjectState < glmu.internal.Base
    
    properties
        list
        targets
        current = 0
    end

    properties(Abstract)
        newFcn
    end

    methods(Abstract)
        New
        Delete
    end
    
    methods(Access = protected)
        function id = Gen(obj,n)
            if nargin < 2, n=1; end

            jb = javabuffer(zeros(n,1,'int32'));
            obj.newFcn(obj.gl,n,jb.p);
            id = jb.array;

            obj.list(end+1:end+n) = id;
        end

        function id = Create(obj,varargin)
            id = obj.newFcn(obj.gl,varargin{:});
            obj.list(end+1) = id;
        end
    end
end


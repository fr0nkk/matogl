classdef ObjectState < glmu.internal.Base
    
    properties
        targets
        current = 0
        toDelete
    end

    properties(Abstract)
        newFcn
        delFcn
    end

    methods(Abstract)
        New
        Delete
    end

    methods
        function DelayedDelete(obj,id)
            obj.toDelete = [obj.toDelete ; id(:)];
%             disp(func2str(obj.delFcn))
%             disp(id)
        end

        function CleanUp(obj)
            if isempty(obj.toDelete), return, end
            obj.Delete(obj.toDelete);
            obj.toDelete = [];
        end
    end
    
    methods(Access = protected)
        function id = Gen(obj,n)
            if nargin < 2, n=1; end

            jb = javabuffer(zeros(n,1,'int32'));
            obj.newFcn(obj.gl,n,jb.p);
            id = jb.array;
%             disp(func2str(obj.newFcn))
%             disp(id)
        end

        function id = Create(obj,varargin)
            id = obj.newFcn(obj.gl,varargin{:});
%             disp(func2str(obj.newFcn))
%             disp(id)
        end        

        function DeleteN(obj,id)
            n = numel(id);
            b = javabuffer(id,'int32');
            obj.delFcn(obj.gl,n,b.p);
        end

        function Delete1(obj,id)
            for i=1:numel(id)
                obj.delFcn(obj.gl,id(i))
            end
        end
        
    end
end


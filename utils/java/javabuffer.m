classdef javabuffer < handle
    
    properties
        p % java buffer
        sz
        capacity
        javaType
        matType
        bytePerValue
    end
    
    methods
        function obj = javabuffer(data,matType)
            if nargin == 0, return, end
            if isa(data,'javabuffer'), obj = data; return, end
            if nargin < 2 || isempty(matType)
                matType = class(data);
            else
                data = cast(data,matType);
            end
            obj.matType = matType;
            [obj.javaType,obj.bytePerValue] = javatype(obj.matType);
            obj.sz = size(data);
            i = obj.sz > 0;
            obj.capacity = prod(obj.sz(i));
            obj.p = java.nio.([obj.javaType 'Buffer']).allocate(obj.capacity);
            if all(i)
                obj.p.put(data(:));
                obj.p.rewind;
            end
        end

        function data = array(obj,varargin)
            data = obj.p.array;
            if ~strcmp(obj.matType,'char')
                data = typecast(obj.p.array,obj.matType);
            end
            data = reshape(data,obj.sz);
            if nargin > 1
                data = data(varargin{:});
            end
        end
    end
    methods(Static)
        function b = cat(dim,varargin)
            szs = cellfun(@(c) c.sz,varargin,'uni',0);
            szs = vertcat(szs{:});
            n = sum(szs(:,dim));
            sz1 = szs(1,:);
            sz1nd = sz1; sz1nd(dim) = [];
            szsnd = szs; szsnd(:,dim) = [];
            assert(all(sz1nd == szsnd,'all'),'different dimensions');
            sz = sz1; sz(dim) = n;
            types = cellfun(@(c) c.matType,varargin,'uni',0);
            assert(all(strcmp(types,types{1})),'different types');
            b = javabuffer(zeros([sz 0],types{1}));
            for i=1:numel(varargin)
                b.p.put(varargin{i}.p);
                varargin{i}.p.rewind;
            end
            b.p.rewind;
            b.sz = sz;
        end
    end
end


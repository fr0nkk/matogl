classdef Buffer < glmu.internal.Object
    
    properties
        target
        sz
        type
        usage
    end
    
    methods
        function obj = Buffer(target,data,varargin)
            obj.target = obj.Const(target);
            [data,n] = obj.ValidData(data);
            obj.id = obj.state.buffer.New(n);
            obj.sz = repmat([0 0],n,1);
            obj.type = zeros(n,1);
            obj.Edit(data,varargin{:});
        end

        function Bind(obj,i)
            if nargin < 2 && numel(obj.id) == 1, i = 1; end
            obj.state.buffer.Bind(obj.target,obj.id(i));
        end

        function Edit(obj,data,usage)
            if nargin < 3, usage = obj.gl.GL_STATIC_DRAW; end
            [data,nd] = obj.ValidData(data);
            usage = obj.Const(usage,nd);
            utypes = {'','UNSIGNED_'};
            for i=1:nd
                if isempty(data{i}), continue, end
                obj.Bind(i);
                [b,nb,jt,mt] = javabuffer(data{i});
                szb = nb*b.capacity;
                obj.gl.glBufferData(obj.target,szb,b,usage(i));
                obj.sz(i,:) = size(data{i});
                obj.type(i) = obj.Const(['GL_' utypes{startsWith(mt,'u')+1} upper(jt)]);
                obj.usage(i,1) = usage(i);
            end
        end
    end
    methods(Static)
        function [data,n] = ValidData(data)
            if ~iscell(data); data = {data}; end
            n = numel(data);
        end
    end
end


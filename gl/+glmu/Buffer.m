classdef Buffer < glmu.internal.Object
    
    properties
        target
        sz
        type
        usage
        bytePerVertex
        bytePerValue
    end
    
    methods
        function obj = Buffer(target,data,varargin)
            % target = GL buffer target
            % data = data | {data data}
            %   [m x n] where m is the number of elements per vertex and n is the number of vertices
            %   if data is [], the buffer is created but not set
            %   multiple empty possible with { [] , [] }
            % optional usage = GL usage, default GL_STATIC_DRAW
            if isa(target,'glmu.Buffer'), obj = target; return, end
            obj.target = obj.Const(target);
            [data,n] = obj.ValidData(data);
            obj.id = obj.state.buffer.New(n);
            obj.sz = repmat([0 0],n,1);
            obj.type = zeros(n,1);
            obj.bytePerValue = zeros(n,1);
            obj.bytePerVertex = zeros(n,1);
            obj.Edit(data,varargin{:});
        end

        function i = Bind(obj,i,target)
            if nargin < 2 && numel(obj.id) == 1, i = 1; end
            if nargin < 3, target = obj.target; end
            obj.state.buffer.Bind(target,obj.id(i));
        end

        function Edit(obj,data,usage)
            % data = data | {data data}
            %   [m x n] where m is the number of elements per vertex and n is the number of vertices
            %   if data is [], the buffer is not set. {[] data} only sets the second buffer
            % optional usage = GL usage, default GL_STATIC_DRAW
            if nargin < 3, usage = obj.gl.GL_STATIC_DRAW; end
            [data,nd] = obj.ValidData(data);
            usage = obj.Const(usage,nd);
            utypes = {'','UNSIGNED_'};
            for i=1:nd
                if isempty(data{i}), continue, end
                obj.Bind(i);
                if ~isa(data{i},'javabuffer')
                    b = javabuffer(data{i});
                else
                    b = data{i};
                end
                obj.bytePerValue(i) = b.bytePerValue;
                szb = obj.bytePerValue(i)*b.capacity;
                obj.gl.glBufferData(obj.target,szb,b.p,usage(i));
                obj.sz(i,:) = b.sz;
                obj.type(i) = obj.Const(['GL_' utypes{startsWith(b.matType,'u')+1} upper(b.javaType)]);
                obj.usage(i,1) = usage(i);
                obj.bytePerVertex(i) = obj.bytePerValue(i)*obj.sz(i,1);
            end
        end

        function BindBase(obj,ibase,varargin)
            i = obj.Bind(varargin{:});
            obj.gl.glBindBufferBase(obj.target,ibase,obj.id(i));
        end

        function delete(obj)
            obj.state.buffer.DelayedDelete(obj.id);
        end
    end
    methods(Static)
        function [data,n] = ValidData(data)
            if ~iscell(data); data = {data}; end
            n = numel(data);
        end
    end
end


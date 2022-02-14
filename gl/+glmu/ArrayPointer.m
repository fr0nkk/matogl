classdef ArrayPointer < glmu.Array
    
    properties
        buffer
        norm
        n = 0
    end
    
    methods
        function obj = ArrayPointer(varargin)
            % optional buffer = glmu.Buffer | buffer data
            % optional normalized = normalize flags for each
            if nargin > 0 && isa(varargin{1},'glmu.ArrayPointer'), obj = varargin{1}; return, end
            obj.Edit(varargin{:});
        end

        function Edit(obj,buffer,normalized,attrib)
            % buffer = glmu.Buffer | buffer data
            % optional normalized = normalize flags for each, default false
            if nargin < 2, return, end
            if nargin < 3, normalized = false; end
            if nargin < 4, attrib = ''; end
            if ~iscell(attrib), attrib = {attrib}; end
            if ~isa(buffer,'glmu.Buffer')
                buffer = glmu.Buffer(obj.gl.GL_ARRAY_BUFFER,buffer);
            end
            nb = numel(buffer.id);
            if nb > 1 && isscalar(attrib), attrib = repmat(attrib,nb,1); end
            obj.norm = obj.Const(normalized,nb);
            obj.Bind;
            for i=1:nb
                buffer.Bind(i,obj.gl.GL_ARRAY_BUFFER);
                sz = buffer.sz(i,1);
                type = buffer.type(i);
                args = {i-1, sz, type};
                if isempty(attrib{i})
                    obj.gl.glVertexAttribPointer(args{:},obj.norm(i),0,0);
                else
                    f = str2func(['glVertexAttrib' attrib{i} 'Pointer']);
                    f(obj.gl,args{:},0,0);
                end
                
                obj.gl.glEnableVertexAttribArray(i-1)
            end
            obj.n = min(buffer.sz(:,2));
            obj.buffer = buffer;
        end

    end
end


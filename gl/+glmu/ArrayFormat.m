classdef ArrayFormat < glmu.Array
    
    properties
        nBuffers = 0;
    end
    
    methods
        function obj = ArrayFormat(varargin)
            if nargin > 0 && isa(varargin{1},'glmu.ArrayFormat'), obj = varargin{1}; return, end
            obj.Edit(varargin{:});
        end

        function Edit(obj,location,nPerVertex,type,normalized)
            if nargin < 2, return, end
            if nargin < 5, normalized = false; end
            
            nb = numel(location);
            obj.nBuffers = nb;
            if isscalar(nPerVertex) && nb > 1, nPerVertex = repmat(nPerVertex,nb,1); end
            type = obj.Const(type,nb);
            normalized = obj.Const(normalized,nb);
            
            obj.Bind;
            for i=1:nb
                obj.gl.glEnableVertexAttribArray(location(i));
                obj.gl.glVertexAttribFormat(location(i), nPerVertex(i), type(i), normalized(i), 0);
                obj.gl.glVertexAttribBinding(location(i), i-1);
            end
        end

    end
end


classdef ArrayFormat < glmu.internal.Drawable
    
    properties
        array
        primitive
    end
    
    methods
        function obj = ArrayFormat(program,primitive,varargin)
            obj@glmu.internal.Drawable(program);
            obj.array = glmu.ArrayFormat(varargin{:});
            obj.primitive = obj.Const(primitive,1);
        end

        function DrawFcn(obj,buffers,offsets,counts)
            n = numel(buffers);
            if nargin < 3, offsets = 0; end
            if isscalar(offsets), offsets = repmat(offsets,n,1); end
            if nargin < 4, counts = cellfun(@(c) min(c.sz(:,2)),buffers); end
            obj.array.Bind;

            for i=1:n
                B = buffers{i};
                b = com.jogamp.common.nio.PointerBuffer.allocate(2);
                obj.gl.glBindVertexBuffers(0,numel(B.id),B.id,offsets(i),b,B.bytePerVertex,0);
                obj.gl.glDrawArrays(obj.primitive,0,counts(i));
            end
        end
    end
end



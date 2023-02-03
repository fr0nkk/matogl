classdef MultiArray < glmu.internal.Drawable
    
    properties
        array
        primitive
    end
    
    methods
        function obj = MultiArray(program,primitive,array)
            obj@glmu.internal.Drawable(program);
            obj.primitive = obj.Const(primitive,1);
            obj.array = glmu.Array(array);
        end

        function DrawFcn(obj,offset,count)
            if nargin < 2, offset = 0; end
            n = obj.array.Bind;
            if nargin < 3, count = n; end
            drawCount = numel(offset);
            offset = javabuffer(int32(offset));
            count = javabuffer(int32(count));
            obj.gl.glMultiDrawArrays(obj.primitive,offset.p,count.p,drawCount);
        end
    end
end


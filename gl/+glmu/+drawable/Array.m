classdef Array < glmu.internal.Drawable
    
    properties
        array
        primitive
        element
    end
    
    methods
        function obj = Array(program,primitive,array)
            obj@glmu.internal.Drawable(program)
            obj.array = glmu.ArrayPointer(array);
            obj.primitive = obj.Const(primitive,1);
        end

        function DrawFcn(obj,offset,count)
            if nargin < 2, offset = 0; end
            if nargin < 3, count = obj.array.n; end
            obj.array.Bind;
            obj.gl.glDrawArrays(obj.primitive,offset,count);
        end
    end
end


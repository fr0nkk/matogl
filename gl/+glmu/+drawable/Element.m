classdef Element < glmu.internal.Drawable
    
    properties
        array
        primitive
        element
    end
    
    methods
        function obj = Element(program,primitive,element,varargin)
            obj@glmu.internal.Drawable(program)
            obj.array = glmu.ArrayPointer(varargin{:});
            obj.primitive = obj.Const(primitive,1);
            if ~isa(element,'glmu.Buffer')
                element = glmu.Buffer(obj.gl.GL_ELEMENT_ARRAY_BUFFER,uint32(element));
            end
            obj.element = element;
        end

        function DrawFcn(obj,offset,count)
            if nargin < 2, offset = 0; end
            if nargin < 3, count = prod(obj.element.sz); end
            obj.array.Bind;
            obj.element.Bind;
            obj.gl.glDrawElements(obj.primitive,count,obj.element.type,offset);
        end
    end
end


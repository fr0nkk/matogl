classdef Array < glmu.internal.Drawable
    
    properties
        array
        primitive
        element
    end
    
    methods
        function obj = Array(array,program,primitive)
            obj@glmu.internal.Drawable(program)
            obj.array = glmu.Array(array);
            obj.primitive = obj.Const(primitive,1);
        end
        
        function SetElement(obj,element)
            % element = glmu.Buffer(GL_ELEMENT_ARRAY_BUFFER) | ElementIndices
            if ~isa(element,'glmu.Buffer')
                element = glmu.Buffer(obj.gl.GL_ELEMENT_ARRAY_BUFFER,uint32(element));
            end
            obj.element = element;
        end

        function DrawFcn(obj,offset,count)
            if nargin < 2, offset = 0; end
            n = obj.array.Bind;
            if isempty(obj.element)
                if nargin < 3, count = n; end
                obj.gl.glDrawArrays(obj.primitive,offset,count);
            else
                if nargin < 3, count = prod(obj.element.sz); end
                obj.element.Bind;
                obj.gl.glDrawElements(obj.primitive,count,obj.element.type,offset);
            end
        end
    end
end

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
            if ~isa(element,'glmu.VertexAttrib')
                element = glmu.VertexAttrib.FromData(uint32(element),obj.gl.GL_ELEMENT_ARRAY_BUFFER,'GL_STATIC_DRAW','integer');
                % element = glmu.Buffer(uint32(element),obj.gl.GL_ELEMENT_ARRAY_BUFFER);
            end
            obj.element = element;
        end

        function DrawFcn(obj,offset,count)
            if nargin < 2, offset = 0; end
            if nargin < 3, count = obj.element.nbDims * obj.element.nbVertex; end
            obj.array.Bind;
            obj.element.buffer.Bind;
            % obj.gl.glDrawElements(obj.primitive,count,obj.element.type,offset*obj.element.bytePerVertex);
            obj.gl.glDrawElements(obj.primitive,count,obj.element.type,obj.element.offset+offset);
        end

        % function EditElement(obj,ind)
        %     obj.array.Bind;
        %     obj.element.Edit({ind});
        % end
    end
end


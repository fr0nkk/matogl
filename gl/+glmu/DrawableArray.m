classdef DrawableArray < glmu.internal.Object
    
    properties
        show = 1;
        array
        element
        program
        uni = struct
        % uni.(variableName) = value -> this uniform variable will be updated before every Draw() call of this object
        primitive
        textures = {};
        samplers = {};
    end
    
    methods
        function obj = DrawableArray(array,program,primitive)
            % array = glmu.Array | glmu.Buffer, {bufferData}
            % program = glmu.Program | {glmu.Shader} | 'shaderName'
            % primitive = GL primitive
            obj.array = glmu.Array(array);
            obj.program = glmu.Program(program);
            obj.primitive = obj.Const(primitive,1);
        end

        function SetElement(obj,element)
            % element = glmu.Buffer(GL_ELEMENT_ARRAY_BUFFER) | ElementIndices
            if ~isa(element,'glmu.Buffer')
                element = glmu.Buffer(obj.gl.GL_ELEMENT_ARRAY_BUFFER,uint32(element));
            end
            obj.element = element;
        end

        function AddTexture(obj,sampler,varargin)
            % sampler = uniform sampler variable name
            % varargin = glmu.Texture | args for glmu.Texture(varargin{:})
            i = size(obj.textures,1)+1;
            obj.textures{i} = glmu.Texture(varargin{:});
            obj.samplers{i} = sampler;
        end

        function Draw(obj,offset,count)
            if ~obj.show, return, end
            obj.program.Use;
            obj.program.SetUniforms(obj.uni);
            n = obj.array.Bind;
            for i=1:numel(obj.textures)
                obj.textures{i}.PrepareDraw(obj.program,obj.samplers{i})
            end
            if nargin < 2, offset = 0; end
            
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


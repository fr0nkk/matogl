classdef DrawableArray < glmu.internal.Object
    
    properties
        show = 1;
        array
        element
        program
        uni = struct
        type
        textures = {};
        samplers = {};
    end
    
    methods
        function obj = DrawableArray(data,program,type)
            switch class(data)
                case 'glmu.Buffer'
                    array = glmu.Array(data);
                case 'glmu.Array'
                    array = data;
                otherwise
                    buffer = glmu.Buffer(obj.gl.GL_ARRAY_BUFFER,data);
                    array = glmu.Array(buffer);
            end

            if ~isa(program,'glmu.Program')
                program = glmu.Program(program);
            end

            obj.array = array;
            obj.program = program;
            obj.type = obj.Const(type,1);
        end

        function SetElement(obj,element)
            if ~isa(element,'glmu.Buffer')
                element = glmu.Buffer(obj.gl.GL_ELEMENT_ARRAY_BUFFER,{uint32(element)});
            end
            obj.element = element;
        end

        function AddTexture(obj,sampler,varargin)
            if isa(varargin{1},'glmu.Texture')
                texture = varargin{1};
            else
                texture = glmu.Texture(varargin{:});
            end
            i = size(obj.textures,1)+1;
            obj.textures{i} = texture;
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
                obj.gl.glDrawArrays(obj.type,offset,count);
            else
                if nargin < 3, count = prod(obj.element.sz); end
                obj.element.Bind;
                obj.gl.glDrawElements(obj.type,count,obj.element.type,offset);
            end
        end

    end
end


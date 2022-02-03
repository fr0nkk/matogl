classdef Drawable < glmu.internal.Object
    
    properties
        program
        textures = {}
        samplers = {}
        show = 1
        uni = struct
    end
    
    methods
        function obj = Drawable(program)
            obj.program = glmu.Program(program);
        end
        
        function AddTexture(obj,sampler,varargin)
            % sampler = uniform sampler variable name
            % varargin = glmu.Texture | args for glmu.Texture(varargin{:})
            i = size(obj.textures,1)+1;
            obj.textures{i} = glmu.Texture(varargin{:});
            obj.samplers{i} = sampler;
        end

        function Draw(obj,varargin)
            if ~obj.show, return, end
            obj.program.Use;
            obj.program.SetUniforms(obj.uni);
            for i=1:numel(obj.textures)
                obj.textures{i}.PrepareDraw(obj.program,obj.samplers{i})
            end
            obj.DrawFcn(varargin{:});
        end
    end
    methods(Abstract)
        DrawFcn(obj,varargin)
    end
end


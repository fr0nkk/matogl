classdef Text < glmu.internal.Object
    
    properties
        array
        str = {}
        sz = [];
        rgba = zeros(0,4);
        model = {};
        
        font
        view = eye(4)
        projection = MProj3D('O',[600 450 -1 200])
    end
    
    properties(Access=private)
        renderer
    end
    
    methods
        function obj = Text(font,varargin)
            % font = 'fontName'
            % varargin = args for New(str,sz,rgba,model)
            obj.array = glmu.Array;
            obj.renderer = obj.state.text.New;
            obj.font = font;
            if nargin > 1
                obj.Add(varargin{:});
            end
        end

        function Add(obj,str,sz,rgba,model)
            % str = char array to render
            % sz = font size
            % optional rgba = [r g b a] color property of the text, default is [0.5 0.5 0.5 1] (gray opaque)
            % optional model : [4x4] matrix model transformation
            if nargin < 4, rgba = [0.5 0.5 0.5 1]; end
            if nargin < 5, model = eye(4); end
            i = numel(obj.str)+1;
            obj.str{i} = str;
            obj.sz(i) = sz;
            obj.rgba(i,:) = rgba;
            obj.model{i} = model;
        end
        
        function Draw(obj)
            obj.array.Bind;
            mv = cellfun(@(c) obj.view * c,obj.model,'uni',0);
            obj.renderer.Render(obj.font,obj.str,obj.sz,obj.rgba,mv,obj.projection);
            obj.state.program.current = 0;
        end
    end
end


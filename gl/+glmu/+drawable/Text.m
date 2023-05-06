classdef Text < glmu.internal.Object
    
    properties(Transient)
        array

        str
        sz
        rgba = zeros(0,4);
        view
        model
        proj
        font
        anchor_point
    end
    
    properties(Access=private)
        strb
        renderer
    end
    
    methods
        function obj = Text(str,sz,rgba,view,model,proj,font,anchor_point)
            if nargin < 1, str = 'glmu.drawable.Text'; end
            if nargin < 2, sz = 10; end
            if nargin < 3, rgba = [1 1 0 1]; end
            if nargin < 4, view = eye(4); end
            if nargin < 5, model = eye(4); end
            if nargin < 6, proj = MProj3D('O',[600 450 -1 200]); end
            if nargin < 7, font = 'Arial'; end
            if nargin < 8, anchor_point = [0 0]; end
            
            obj.str = str;
            obj.sz = sz;
            obj.rgba = rgba;
            obj.view = view;
            obj.model = model;
            obj.proj = proj;
            obj.font = font;
            obj.anchor_point = anchor_point;

            obj.array = glmu.Array;
            obj.renderer = obj.state.text.New;
        end
        
        function Draw(obj)
            obj.DrawViewModel(obj.view * obj.model);
        end

        function DrawViewModel(obj,mv)
            obj.array.Bind;
            obj.renderer.Render(obj.font,obj.strb,obj.sz,obj.rgba,mv,obj.proj,obj.anchor_point);
            obj.state.program.current = 0;
        end

        function set.str(obj,v)
            obj.strb = javabuffer(v);
        end
    end
end


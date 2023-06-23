classdef JFont < JObj
    
    properties
        constructor = @getFont
        parent
    end

    properties(Transient)
        family
        style
        size
    end

    properties(Constant)
        PLAIN = java.awt.Font.PLAIN
        BOLD = java.awt.Font.BOLD
        ITALIC = java.awt.Font.ITALIC
    end
    
    methods
        function obj = JFont(parent)
            obj@JObj(parent);
            obj.parent = parent;
        end

        function f = get.family(obj)
            f = char(obj.java.getFamily);
        end

        function set.family(obj,f)
            obj.parent.setFont(JFont.new(f,obj.style,obj.size));
        end

        function sz = get.size(obj)
            sz = obj.java.getSize;
        end

        function set.size(obj,sz)
            obj.parent.setFont(JFont.new(obj.family,obj.style,sz));
        end

        function s = get.style(obj)
            s = obj.java.getStyle;
        end

        function set.style(obj,s)
            obj.parent.setFont(JFont.new(obj.family,s,obj.size));
        end

    end

    methods(Static)
        function f = AvilableFonts()
            f = arrayfun(@char,java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getAvailableFontFamilyNames,'uni',0);
        end

        function F = new(family,style,size)
            F = java.awt.Font(family,style,size);
        end
    end
end


classdef JFrame < JComponent
    % basic JFrame display in matlab

    properties(Constant)
        JClass = 'javax.swing.JFrame'
        isEDT = false
    end

    properties
        title
    end
    
    methods
        
        function obj = JFrame(title,sz)
            if nargin < 1, title = 'JFrame'; end
            if nargin < 2, sz = [600 450]; end
            sz = double(sz);
            obj.title = title;
            obj.size = sz;
%             obj.java.setUndecorated(1);
            obj.java.setDefaultCloseOperation(obj.java.HIDE_ON_CLOSE); % will be disposed by the delete fcn
            obj.java.setLocationRelativeTo([]); % set position to center of screen
            obj.java.setVisible(true);
            
            obj.setCallback('WindowClosing',@(~,~) obj.delete);
        end

        function set.title(obj,t)
            obj.java.setTitle(t);
        end

        function t = get.title(obj)
            t = char(obj.java.getTitle);
        end

        function delete(obj)
            obj.java.dispose;
        end
        
    end
end


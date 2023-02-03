classdef jFrame < javacallbackmanager
    % basic JFrame display in matlab

    properties
        java % javax.swing.JFrame
    end
    
    methods
        
        function obj = jFrame(name,sz)
            if nargin < 1, name = 'javax.swing.JFrame'; end
            if nargin < 2, sz = [600 450]; end
            sz = double(sz);
            obj.java = javax.swing.JFrame(name);
            obj.java.setDefaultCloseOperation(obj.java.DISPOSE_ON_CLOSE);
            obj.java.setSize(sz(1),sz(2));
            obj.java.setLocationRelativeTo([]); % set position to center of screen
            obj.java.setVisible(true);
            
            obj.populateCallbacks(obj.java);
            obj.setCallback('WindowClosed',@(~,~) obj.delete);
        end

        function add(obj,children)
            obj.java.add(children);
            obj.java.revalidate;
            obj.java.repaint;
        end
        
        function delete(obj)
            obj.rmCallback;
            obj.java.dispose;
        end
        
    end
end


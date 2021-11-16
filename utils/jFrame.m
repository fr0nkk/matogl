classdef jFrame < javacallbackmanager
    % basic JFrame display in matlab

    properties
        jf % javax.swing.JFrame
    end
    
    methods
        
        function obj = jFrame(name,sz)
            if nargin < 1, name = 'javax.swing.JFrame'; end
            if nargin < 2, sz = [600 450]; end
            sz = double(sz);
            obj.jf = javax.swing.JFrame(name);
            obj.jf.setDefaultCloseOperation(obj.jf.DISPOSE_ON_CLOSE);
            obj.jf.setSize(sz(1),sz(2));
            obj.jf.setLocationRelativeTo([]); % set position to center of screen
            obj.jf.setVisible(true);
            
            obj.populateCallbacks(obj.jf);
            obj.setCallback('WindowClosed',@(~,~) obj.delete);
        end
        
        function delete(obj)
            obj.rmCallback;
            obj.jf.dispose;
        end
        
    end
end


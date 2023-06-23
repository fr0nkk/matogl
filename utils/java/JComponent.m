classdef JComponent < JObj & JChildParent & javacallbackmanager

    properties
        name
        size
        preferredSize
        minimumSize
        maximumSize
        Font
    end
    
    methods
        function obj = JComponent(varargin)
            obj@JObj(varargin{:});
            obj.populateCallbacks(obj.java);
        end
        
        function comp = add(obj,comp,varargin)
            obj.java.add(comp.java,varargin{:});
            obj.addChild(comp);
        end

        function refresh(obj)
            obj.java.revalidate;
            obj.java.repaint;
        end

        function delete(obj)
%             disp('del')
            obj.rmCallback;
            p = obj.java.getParent;
            if ~isempty(p)
                p.remove(obj.java);
            end
            
        end

        function F = get.Font(obj)
            F = JFont(obj.java);
        end
        
        function n = get.name(obj)
            n = char(obj.java.getName);
        end

        function set.name(obj,n)
            obj.java.setName(n);
        end

        function sz = get.size(obj)
            sz = [obj.java.getWidth obj.java.getHeight];
        end

        function set.size(obj,sz)
            obj.java.setSize(sz(1),sz(2));
        end

        function sz = get.preferredSize(obj)
            D = obj.java.getPreferredSize;
            sz = [D.getWidth D.getHeight];
        end

        function set.preferredSize(obj,sz)
            D = java.awt.Dimension(sz(1),sz(2));
            obj.java.setPreferredSize(D);
        end

        function sz = get.minimumSize(obj)
            D = obj.java.getMinimumSize;
            sz = [D.getWidth D.getHeight];
        end

        function set.minimumSize(obj,sz)
            D = java.awt.Dimension(sz(1),sz(2));
            obj.java.setMinimumSize(D);
        end

        function sz = get.maximumSize(obj)
            D = obj.java.getMaximumSize;
            sz = [D.getWidth D.getHeight];
        end

        function set.maximumSize(obj,sz)
            D = java.awt.Dimension(sz(1),sz(2));
            obj.java.setMaximumSize(D);
        end

    end
end


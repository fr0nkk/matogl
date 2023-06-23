classdef JChildParent < handle
    %JCHILDPARENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        child = {}
        parent
    end
    
    methods
        function comp = addChild(obj,comp)
            obj.child{end+1} = comp;
            comp.parent = obj;
        end

        function comp = rmChild(obj,comp,newChildParent)
            if nargin < 3, newChildParent = []; end
            tf = cellfun(@(c) eq(comp,c),obj.child);
            obj.child(tf) = [];
            comp.parent = newChildParent;
        end

        function C = validateChilds(obj)
            obj.child(~cellfun(@isvalid,obj.child)) = [];
            C = obj.child;
        end

        function delete(obj)
            cellfun(@delete,obj.child);
            if ~isempty(obj.parent) && isvalid(obj.parent)
                obj.parent.validateChilds;
%                 obj.parent.child(~cellfun(@isvalid,obj.parent.child)) = [];
            end
        end
    end
end


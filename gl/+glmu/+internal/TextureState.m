classdef TextureState < glmu.internal.ObjectState
    
    properties
        newFcn = @glGenTextures
        activeUnit = 0;
        % current : target1 target2 target2
%             unit0 [id1     id2     id3    ]
%             unit1 [id4     id5     id6    ]
    end
    
    methods
        
        function id = New(obj,varargin)
            id = obj.Gen(varargin{:});
        end

        function Active(obj,unit)
            if obj.activeUnit == unit, return, end
            obj.gl.glActiveTexture(obj.gl.GL_TEXTURE0+unit);
            obj.activeUnit = unit;
        end

        function Bind(obj,target,id)

            i = find(target == obj.targets,1);
            if isempty(i)
                i = numel(obj.targets)+1;
                obj.targets(i) = target;
                obj.current(:,i) = 0;
            end
            iu = obj.activeUnit+1;
            if size(obj.current,1) >= iu && obj.current(iu,i) == id, return, end
            obj.gl.glBindTexture(target,id);
            obj.current(iu,i) = id;
        end

        function Valid(obj,unit,target,id)
            i = find(target == obj.targets,1);
            if obj.current(unit+1,i) == id, return, end
            obj.Active(unit);
            obj.Bind(target,id);
        end

        function Delete(obj,id)
            
        end

    end
end


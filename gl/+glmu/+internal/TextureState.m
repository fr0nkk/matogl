classdef TextureState < glmu.internal.ObjectState
    
    properties
        newFcn = @glGenTextures
        delFcn = @glDeleteTextures
        activeUnit = 0;
        % current : target1 target2 target2
%             unit0 [id1     id2     id3    ]
%             unit1 [id4     id5     id6    ]

        imageUnit % unit0 [txId lvl layered layer access format]
    end
    
    properties(Access=private)
        targetsDim
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
            if numel(obj.current) >= unit+1 && obj.current(unit+1,i) == id, return, end
            obj.Active(unit);
            obj.Bind(target,id);
        end

        function ImageUnit(obj,unit,id,level,layered,layer,access,format)
            error('todo')
            i = unit+1;
            new = int32([id level layered layer access format]);
            if size(obj.imageUnit,1) >= i
%                 if all(new == obj.imageUnit(i,:)), return, end
            end
            obj.gl.glBindImageTexture(unit,id,level,layered,layer,access,format);
            obj.imageUnit(i,:) = new;
%             disp('im')
        end

        function Delete(obj,id)
            obj.DeleteN(id);
        end

        function ndim = GetDim(obj,target)
            if isempty(obj.targetsDim)
                D1 = {'GL_TEXTURE_1D'
                    'GL_PROXY_TEXTURE_1D'};
                D2 = {'GL_TEXTURE_2D'
                    'GL_PROXY_TEXTURE_2D'
                    'GL_TEXTURE_1D_ARRAY'
                    'GL_PROXY_TEXTURE_1D_ARRAY'
                    'GL_TEXTURE_RECTANGLE'
                    'GL_PROXY_TEXTURE_RECTANGLE'
                    'GL_TEXTURE_CUBE_MAP_POSITIVE_X'
                    'GL_TEXTURE_CUBE_MAP_NEGATIVE_X'
                    'GL_TEXTURE_CUBE_MAP_POSITIVE_Y'
                    'GL_TEXTURE_CUBE_MAP_NEGATIVE_Y'
                    'GL_TEXTURE_CUBE_MAP_POSITIVE_Z'
                    'GL_TEXTURE_CUBE_MAP_NEGATIVE_Z'
                    'GL_PROXY_TEXTURE_CUBE_MAP'
                    'GL_TEXTURE_2D_MULTISAMPLE'
                    'GL_PROXY_TEXTURE_2D_MULTISAMPLE'};
                D3 = {'GL_TEXTURE_3D'
                    'GL_PROXY_TEXTURE_3D'
                    'GL_TEXTURE_2D_ARRAY'
                    'GL_PROXY_TEXTURE_2D_ARRAY'};
                obj.targetsDim = {obj.Const(D1) obj.Const(D2) obj.Const(D3)};
            end
            ndim = find(cellfun(@(c) any(c==target),obj.targetsDim));
        end

    end
end


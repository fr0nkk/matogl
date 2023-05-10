classdef Texture < glmu.internal.TextureBase
    
    properties
        unit
        target
        ndim
        editFcn
    end
    
    methods
        function obj = Texture(unit,target,varargin)
            if isa(unit,'glmu.Texture'), obj=unit; return, end
            obj.unit = unit;
            obj.id = obj.state.texture.New(1);
            obj.target = obj.Const(target,1);
            obj.ndim = obj.state.texture.GetDim(obj.target);
            assert(~isempty(obj.ndim),'Invalid texture target');
            obj.editFcn = str2func(sprintf('glTexImage%iD',obj.ndim));
            obj.Edit(varargin{:});
        end
        
        function sz = Edit(obj,data,format,genMipMap,internalformat)
            if nargin < 2, return, end
            if nargin < 4, genMipMap = 1; end
            if nargin < 5, internalformat = format; end
            format = obj.Const(format,1);
            internalformat = obj.Const(internalformat,1);
            if iscell(data)
                sz = data{1};
                type = data{2};
                data = javabuffer();
            else
                if ischar(data) || isstring(data), data = imread(data); end
                if obj.ndim > 1, data = rot90(data,-1); end
                sz = size(data);
                sz = sz(1:obj.ndim);
                data = permute(data,[obj.ndim+1 1:obj.ndim]);
                if isa(data,'double'), data = single(data); end
                data = javabuffer(data);
                utypes = {'','UNSIGNED_'};
                type = ['GL_' utypes{startsWith(data.matType,'u')+1} upper(data.javaType)];
                obj.gl.glPixelStorei(obj.gl.GL_UNPACK_ALIGNMENT, 1);
            end
            type = obj.Const(type,1);
            szArgs = num2cell(sz);
            obj.Bind;
            obj.editFcn(obj.gl,obj.target,0,internalformat,szArgs{:},0,format,type,data.p);
            if genMipMap && ~isempty(data)
                obj.gl.glGenerateMipmap(obj.target);
                if genMipMap > 1
                    obj.Parameter(obj.gl.GL_TEXTURE_MIN_FILTER,obj.gl.GL_LINEAR_MIPMAP_LINEAR);
                    obj.Parameter(obj.gl.GL_TEXTURE_LOD_BIAS,-1);
                end
            else
                obj.Parameter(obj.gl.GL_TEXTURE_MIN_FILTER,obj.gl.GL_LINEAR);
            end
        end

        function EditMultisample(obj,nSample,internalformat,sz)
            internalformat = obj.Const(internalformat);
            obj.Bind;
            obj.gl.glTexImage2DMultisample(obj.target, nSample, internalformat, sz(1), sz(2), obj.gl.GL_TRUE);
        end
        
        function Parameter(obj,param,value)
            obj.Bind;
            obj.gl.glTexParameteri(obj.target,obj.Const(param,1),value);
        end

        function Valid(obj)
            obj.state.texture.Valid(obj.unit,obj.target,obj.id);
        end
        
        function Bind(obj)
            obj.state.texture.Active(obj.unit);
            obj.state.texture.Bind(obj.target,obj.id);
        end

        function delete(obj)
            obj.state.texture.DelayedDelete(obj.id);
        end
    end
end


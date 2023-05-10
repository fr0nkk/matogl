classdef Uniform < glmu.internal.Object
    
    properties
        progid
        elemPerValue
        setFcn
        convertFcn
        transpose = {};
        lastValue = nan
    end
    
    methods
        function obj = Uniform(progid,name,type,transpose)
            % program = glmu.Program
            % name = uniform variable name
            % type = GL_FLOAT_VEC3 etc
            % optional transpose = true/false transpose if matrix
            obj.progid = progid;
            obj.id = obj.gl.glGetUniformLocation(progid,name);
            if obj.id < 0
                error(['Uniform location for ''' name ''' not found'])
            end
            type = obj.Const(type,1);
            [setFcnStr,obj.convertFcn] = obj.state.program.ConvertType(type,name);
            sz = str2double(regexp(setFcnStr,'\d','match'));
            isMatrix = startsWith(setFcnStr,'Matrix');
            if isMatrix && numel(sz) == 1, sz = [sz sz]; end
            obj.elemPerValue = prod(sz);
            obj.setFcn = str2func(['glUniform' setFcnStr 'v']);
            if isMatrix
                if nargin < 5, transpose = false; end
                obj.transpose = {obj.Const(transpose,1)};
            end
        end

        function Set(obj,value)
            % vlue = numerical | java.nio.Buffer | glmu.Texture (for
            % sampler2D) | glmu.TextureImage (for image2D)
            if isempty(value), return, end
            if isa(value,'glmu.internal.TextureBase')
                arrayfun(@(a) a.Valid,value);
                value = vertcat(value.unit);
            end
            try
                if all(obj.lastValue == value,'all'), return, end
            catch
            end
            obj.InternalSet(value);
            obj.lastValue = value;
        end
    end
    methods(Access=private)
        function InternalSet(obj,value)
            if isa(value,'javabuffer')
                n = value.capacity;
            else
                n = numel(value);
                value = javabuffer(obj.convertFcn(value));
            end
            n = n / obj.elemPerValue;
            obj.state.program.Use(obj.progid);
            obj.setFcn(obj.gl,obj.id,n,obj.transpose{:},value.p);
        end
    end
end



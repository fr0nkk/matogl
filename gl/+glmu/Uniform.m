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
            [setFcnStr,obj.convertFcn] = ConvertType(obj.gl,type,name);
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
            % vlue = numerical | java.nio.Buffer
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

function [setFcnStr,matFcn] = ConvertType(gl,type,name)
    persistent T
    if isempty(T) || ~ismember(type,T.glType)
        % build lookup
        types = {
            'GL_FLOAT',         'f',    @single
            'GL_INT',           'i',    @int32
            'GL_UNSIGNED_INT',  'ui',   @uint32
            'GL_DOUBLE',        'd',    @double
            'GL',               'i',    @int32
            };
        sizes = {
            '',                 '1'
            '_VEC2',            '2'
            '_VEC3',            '3'
            '_VEC4',            '4'
            '_MAT2',            'Matrix2'
            '_MAT3',            'Matrix3'
            '_MAT4',            'Matrix4'
            '_MAT2x3',          'Matrix2x3'
            '_MAT2x4',          'Matrix2x4'
            '_MAT3x2',          'Matrix3x2'
            '_MAT3x4',          'Matrix3x4'
            '_MAT4x2',          'Matrix4x2'
            '_MAT4x3',          'Matrix4x3'
            '_SAMPLER_1D',      '1'
            '_SAMPLER_2D',      '1'
            '_SAMPLER_3D',      '1'
    
            };
        fcn = arrayfun(@(a) repmat(a,size(sizes,1),1),types(:,3),'uni',0);
        temp = cellfun(@(c1,c2,c3) {strcat(c1,sizes(:,1)) strcat(sizes(:,2),c2)}, types(:,1),types(:,2),'uni',0);
        temp = vertcat(temp{:});
        T = table(vertcat(temp{:,1}), vertcat(temp{:,2}), vertcat(fcn{:}),'VariableNames',{'glTypeStr','glFcn','matFcn'});
    
        T.glType = cellfun(@(c) GetType(gl,c),T.glTypeStr);
        T = T(T.glType ~= -1,:);
    end
    
    i = type == T.glType;
    if ~any(i)
        error(['No type defined for ' name])
    end
    setFcnStr = T.glFcn{i};
    matFcn = T.matFcn{i};

end

function t = GetType(gl,name)
    try
        t = gl.(name);
    catch
        t = -1;
    end
end


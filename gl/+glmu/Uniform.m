classdef Uniform < glmu.internal.Object
    
    properties
        prog
        elemPerValue
        setFcn
        convertFcn
        transpose = {};
        lastValue = nan
    end
    
    methods
        function obj = Uniform(prog,name,type,transpose)
            obj.prog = prog;
            obj.id = obj.gl.glGetUniformLocation(prog.id,name);
            if obj.id < 0
                error(['Uniform location for ''' name ''' not found'])
            end
            [type,obj.convertFcn] = ConvertType(type);
            sz = str2double(regexp(type,'\d','match'));
            isMatrix = startsWith(type,'Matrix');
            if isMatrix && numel(sz) == 1, sz = [sz sz]; end
            obj.elemPerValue = prod(sz);
            obj.setFcn = str2func(['glUniform' type 'v']);
            if isMatrix
                if nargin < 5, transpose = false; end
                obj.transpose = {obj.Const(transpose,1)};
            end
        end

        function Set(obj,value)
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
            if isa(value,'java.nio.Buffer')
                n = value.capacity;
            else
                n = numel(value);
                value = javabuffer(obj.convertFcn(value));
            end
            n = n / obj.elemPerValue;
            obj.prog.Use;
            obj.setFcn(obj.gl,obj.id,n,obj.transpose{:},value);
        end
    end
end

function [type,mlType] = ConvertType(type)
persistent types
if isempty(types)
    slTypes1 = {  'bool'  'int'   'uint'   'float'  'double'}';
    glTypes = {   'i'     'i'     'ui'     'f'      'd'}';
    mlTypes = {   'int32' 'int32' 'uint32' 'single' 'double'}';
    slvecTypes = {'b'    'i'   'u'    ''      'd'}';
    slmatTypes = {'', 'd'}';
    glmatTypes = {'f' 'd'}';
    mlmatTypes = {'single' 'double'}';
    n = {'2' '3' '4'}';
    slvec = 'vec';
    slmat = 'mat';
    glmat = 'Matrix';
    u1 = [slTypes1 strcat('1',glTypes) mlTypes];
    u234 = cellfun(@(c) [strcat(slvecTypes,slvec,c) strcat(c,glTypes) mlTypes],n,'uni',0);
    u234 = vertcat(u234{:});
    m1 = cellfun(@(c) [strcat(slmatTypes,slmat,c) strcat(glmat,c,glmatTypes) mlmatTypes],n,'uni',0);
    m1 = vertcat(m1{:});
    nn = numel(n);
    mX = cell(nn^2,1);
    for i=1:nn
        for j=1:nn
            d = strjoin(n([i j]),'x');
            mX{(i-1)*nn+j} = [strcat(slmatTypes,slmat,d) strcat(glmat,d,glmatTypes) mlmatTypes];
        end
    end
    mX = vertcat(mX{:});

    samplers = {'1D' '2D' '3D' 'Cube' '2DRect' '1DArray' '2DArray' 'CubeArray' 'Buffer' '2DMS' '2DMSArray'}';
    g = {'' 'i' 'u'};
    samp = cellfun(@(c) [strcat(c,'sampler',samplers) repmat({'1i' 'int32'},numel(samplers),1)],g,'uni',0);
    samp = vertcat(samp{:});
    types = [u1 ; u234 ; m1 ; mX ; samp];


end
i = strcmp(type,types(:,1));
if any(i)
    type = types{i,2};
else
    i = strcmp(type,types(:,2));
    if ~any(i)
        error(['uniform type not found: ' type]);
    end
end

mlType = str2func(types{i,3});


end


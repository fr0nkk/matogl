function out = BuildUniformLookup(gl)

persistent P
if isempty(P)
    P = cell(0,2);
end

c = class(gl);
k = find(strcmp(P(:,1),c));

if isempty(k)
    types = {
        'GL_FLOAT',         'f',    @single
        'GL_INT',           'i',    @int32
        'GL_UNSIGNED_INT',  'ui',   @uint32
        'GL_DOUBLE',        'd',    @double
        'GL_BOOL',          'i',    @int32
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
        '_SAMPLER_2D_MULTISAMPLE',      '1'
        '_SAMPLER_3D',      '1'
        '_IMAGE_2D',        '1'

        };
    fcn = arrayfun(@(a) repmat(a,size(sizes,1),1),types(:,3),'uni',0);
    temp = cellfun(@(c1,c2,c3) {strcat(c1,sizes(:,1)) strcat(sizes(:,2),c2)}, types(:,1),types(:,2),'uni',0);
    temp = vertcat(temp{:});
    T = table(vertcat(temp{:,1}), vertcat(temp{:,2}), vertcat(fcn{:}),'VariableNames',{'glTypeStr','glFcn','matFcn'});

    tf = contains(T.glTypeStr,{'_SAMPLER_','_IMAGE_'});
    T.glFcn(tf) = {'1i'};
    T.matFcn(tf) = {@int32};
    

    T.glType = cellfun(@(c) GetType(gl,c),T.glTypeStr);
    T = T(T.glType ~= -1,:);
    k=height(P)+1;
    P(k,:) = {c T};
end


out = P{k,2};

end

function t = GetType(gl,name)
    try
        t = gl.(name);
    catch
        t = -1;
    end
end
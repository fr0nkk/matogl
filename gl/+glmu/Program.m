classdef Program < glmu.internal.Object
    
    properties
        shaders
        uniforms = struct;
        subroutine = struct; % .stage.name
    end
    
    properties(Access=private)
        shaderTypes = { %ext, GL_Type constant
                        'vert' 'GL_VERTEX_SHADER'
                        'tesc' 'GL_TESS_CONTROL_SHADER'
                        'tese' 'GL_TESS_EVALUATION_SHADER'
                        'geom' 'GL_GEOMETRY_SHADER'
                        'frag' 'GL_FRAGMENT_SHADER'
                        'comp' 'GL_COMPUTE_SHADER'                        
                        };
        subResourcesDir = 'shaders'
    end
    
    methods
        function obj = Program(shaders,varargin)
            % shaders = glmu.Program | {glmu.Shader} | 'shaderName'
            %   when used with 'shaderName', add #N to select the instance N
            % optional preproc : char array to append up top before compilation
            if isa(shaders,'glmu.Program'), obj = shaders; return, end
            cacheProg = '';
            if ischar(shaders)
                cacheProg = shaders;
                [P,name] = obj.state.program.GetCache(cacheProg);
                if ~isempty(P)
                    obj = P;
                    return
                else
                    shaders = obj.GetShaders(name,varargin{:});
                end                
            end
            obj.id = obj.state.program.New();
            if nargin > 0
                obj.Attach(shaders);
                obj.Link();
                obj.DetectUniforms;
                obj.DetectSubroutines
                obj.state.program.SetCache(cacheProg,obj)
            end
        end

        function shaders = GetShaders(obj,name,varargin)
            % name : 'shaderName'
            % optional preproc : char array to append up top before compilation
            d = fullfile(obj.state.resourcesPath,obj.subResourcesDir);
            [fl,dl] = filelist(d,[name '.*.glsl']);
            types = extractBetween(fl,'.','.');
            gltypes = replace(types,obj.shaderTypes(:,1),obj.shaderTypes(:,2));
            ns = numel(gltypes);
            shaders = cell(1,ns);
            for i=1:ns
                src = fileread(fullfile(dl{i},fl{i}));
                shaders{i} = glmu.Shader(gltypes{i},src,varargin{:});
            end
        end
        
        function Attach(obj,shaders)
            for i=1:numel(shaders)
                obj.gl.glAttachShader(obj.id,shaders{i}.id);
            end
            obj.shaders = shaders(:);
        end

        function [v,b] = Get(obj,name)
            [v,b] = glmu.Get(obj.gl,@glGetProgramiv,{obj.id,obj.Const(name)});
        end

        function str = InfoLog(obj)
            [n,b] = obj.Get(obj.gl.GL_INFO_LOG_LENGTH);
            str = char(glmu.Get(obj.gl,@glGetProgramInfoLog,{obj.id,n,b},n,'uint8'))';
        end

        function Link(obj)
            obj.gl.glLinkProgram(obj.id);
            if ~obj.Get(obj.gl.GL_LINK_STATUS)
                log = obj.InfoLog;
                ME = MException('GL:PROGRAM:LinkFailed',log);
                throw(ME);
            end
        end

        function Use(obj)
            obj.state.program.Use(obj.id);
        end

        function Dispatch(obj,x,y,z)
            obj.Use;
            obj.gl.glDispatchCompute(x,y,z);
        end

        function DetectUniforms(obj)
            nbUniforms = obj.Get(obj.gl.GL_ACTIVE_UNIFORMS);
            c = 100;
            bName = javabuffer(zeros(1,c,'uint8'));
            bNameLen = javabuffer(int32(-1));
            bNum = javabuffer(int32(-1));
            bType = javabuffer(int32(-1));
            for i=1:nbUniforms
                obj.gl.glGetActiveUniform( obj.id, i-1, c-1, bNameLen, bNum, bType, bName );
                name = bName.array';
                name = char(name(1:bNameLen.array));
                name = regexprep(name,'\[\d+\]','');
                obj.uniforms.(name) = glmu.Uniform(obj,name,bType.array);
            end
        end

        function DetectSubroutines(obj)
            for i=1:numel(obj.shaders)
                type = obj.shaders{1}.type;
                glTypeName = type2name(obj.gl,type);
                typeName = obj.shaderTypes{strcmp(obj.shaderTypes(:,2),glTypeName),1};
                nb = javabuffer(int32(-1));
                obj.gl.glGetProgramStageiv(obj.id,type,obj.gl.GL_ACTIVE_SUBROUTINES,nb);
                % todo
            end
        end

        function SetUniforms(obj,uni)
            % uni = struct of uniforms and their values
            fn = fieldnames(uni);
            for i=1:numel(fn)
                obj.uniforms.(fn{i}).Set(uni.(fn{i}));
            end
        end

    end
end

function name = type2name(gl,type)
persistent T
if isempty(T)
    names = {
        'GL_VERTEX_SHADER'
        'GL_TESS_CONTROL_SHADER'
        'GL_TESS_EVALUATION_SHADER'
        'GL_GEOMETRY_SHADER'
        'GL_FRAGMENT_SHADER'
        'GL_COMPUTE_SHADER'
        };
    types = getfields(gl,1,names);
    T = table(names,types);
end
name = T.names{T.types == type};
end


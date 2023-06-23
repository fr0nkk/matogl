classdef Program < glmu.internal.Object
    
    properties
        shaders
        uniforms = struct;
        subroutines = struct;
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
    end
    
    methods
        function obj = Program(shaders,varargin)
            % shaders = glmu.Program | {glmu.Shader} | 'shaderName'
            % optional preproc : char array to append up top before compilation
            if isa(shaders,'glmu.Program'), obj = shaders; return, end
            if ischar(shaders)
                shaders = obj.GetShaders(shaders,varargin{:});            
            end
            obj.id = obj.state.program.New();
            if nargin > 0
                obj.Attach(shaders);
                obj.Link();
                obj.DetectUniforms;
                obj.DetectSubroutines;
            end
        end

        function shaders = GetShaders(obj,shaderBasePath,varargin)
            % name : 'shaderName'
            % optional preproc : char array to append up top before compilation
            shdName = [shaderBasePath '.*.glsl'];
            [fl,dl] = filelist(shdName);
            if isempty(fl)
                error('no shader corresponding to: %s',shdName);
            end
            types = extractBetween(fl,'.','.');
            gltypes = obj.state.program.GetShaderType(types);
            ns = numel(gltypes);
            shaders = cell(1,ns);
            for i=1:ns
                src = fileread(fullfile(dl{i},fl{i}));
                shaders{i} = glmu.Shader(gltypes(i),src,varargin{:});
            end
        end
        
        function Attach(obj,shaders)
            for i=1:numel(shaders)
                obj.gl.glAttachShader(obj.id,shaders{i}.id);
            end
            obj.shaders = shaders(:);
        end

        function v = Get(obj,name)
            v = glmu.Get(obj.gl,@glGetProgramiv,{obj.id,obj.Const(name)});
        end

        function str = InfoLog(obj)
            n = obj.Get(obj.gl.GL_INFO_LOG_LENGTH);
            str = glmu.GetStr(obj.gl,@glGetProgramInfoLog,{obj.id},n,2,3,4);
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
            bNum = javabuffer(-1,'int32');
            bType = javabuffer(-1,'int32');
            for i=1:nbUniforms
                name = glmu.GetStr(obj.gl,@glGetActiveUniform,{obj.id, i-1,[],[], bNum.p, bType.p, []},100,3,4,7);
                obj.uniforms = subsasgn(obj.uniforms,cppsubs(name),glmu.Uniform(obj.id,name,bType.array));
            end
        end

        function v = GetStage(obj,stage,name)
            v = glmu.Get(obj.gl,@glGetProgramStageiv,{obj.id,stage,obj.Const(name)});
        end

        function DetectSubroutines(obj)
            for i=1:numel(obj.shaders)
                stage = obj.shaders{i}.type;
                
                n = obj.GetStage(stage,obj.gl.GL_ACTIVE_SUBROUTINE_UNIFORM_LOCATIONS);

                if ~n, continue, end
                sr = cell(1,n);
                for j=1:n
                    name = glmu.GetStr(obj.gl,@glGetActiveSubroutineUniformName,{obj.id, stage, j-1},100,4,5,6);
                    u = glmu.SubroutineUniform(obj.id,stage,name,j-1);
                    obj.uniforms = subsasgn(obj.uniforms,cppsubs(name),u);
                    sr{j} = u;
                end
                sr = horzcat(sr{:});
                % necessary because to change 1 subroutine in opengl, you
                % need to set them all at once
                for j=1:n
                    sr(j).stageSubroutines = sr;
                end

            end
        end

        function SetUniforms(obj,uni)
            % uni = struct of uniforms and their values
            obj.uniset(obj.uniforms,uni);
        end

        function delete(obj)
            obj.state.program.DelayedDelete(obj.id);
        end

    end

    methods(Static)

        function uniset(uniStruct,valuesStruct)
            fn = fieldnames(valuesStruct);
            for i=1:numel(fn)
                v = [valuesStruct.(fn{i})];
                if isempty(v), continue, end
                u = uniStruct.(fn{i});
                if isstruct(u)
                    % recursive
                    for j=1:numel(v)
                        glmu.Program.uniset(u(j),v(j));
                    end
                else
                    % set uniform
                    u(1).Set(v);
                end
            end
        end

    end
end


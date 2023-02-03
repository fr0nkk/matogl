classdef Program < glmu.internal.Object
    
    properties
        shaders
        uniforms = struct;
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
                obj.DetectSubroutines;
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
                name = regexprep(name,'\[\d+\]','');
                obj.uniforms.(name) = glmu.Uniform(obj.id,name,bType.array);
            end
        end

        function v = GetStage(obj,stage,name)
            v = glmu.Get(obj.gl,@glGetProgramStageiv,{obj.id,stage,obj.Const(name)});
        end

        function DetectSubroutines(obj)
            for i=1:numel(obj.shaders)
                stage = obj.shaders{i}.type;
                n = obj.GetStage(stage,obj.gl.GL_ACTIVE_SUBROUTINE_UNIFORM_LOCATIONS);
                if n < 1, continue, end
                for j=1:n
                    name = glmu.GetStr(obj.gl,@glGetActiveSubroutineUniformName,{obj.id, stage, j-1},100,4,5,6);
                    obj.uniforms.(name) = glmu.SubroutineUniform(obj.id,stage,name,j-1);
                end
            end
        end

        function SetUniforms(obj,uni)
            % uni = struct of uniforms and their values
            fn = fieldnames(uni);
            for i=1:numel(fn)
                obj.uniforms.(fn{i}).Set(uni.(fn{i}));
            end
        end

        function delete(obj)
            obj.state.program.DelayedDelete(obj.id);
        end

    end
end



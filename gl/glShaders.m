classdef glShaders < handle
    % helper class to abstract some opengl shader pipeline
    
    properties
        shaderPath
        
        shaderTypes = { %type, gl_type
                        'vert' 'GL_VERTEX_SHADER'
                        'tesc' 'GL_TESS_CONTROL_SHADER'
                        'tese' 'GL_TESS_EVALUATION_SHADER'
                        'geom' 'GL_GEOMETRY_SHADER'
                        'frag' 'GL_FRAGMENT_SHADER'
                        'comp' 'GL_COMPUTE_SHADER'                        
                        };
                    
        prog = struct
        loc_cache = struct
        lastProg int32 = 0;
    end
    
    methods
        function obj = glShaders(shaderPath)
            obj.shaderPath = shaderPath;
        end
        
        function PROG = Init(obj,gl,shaderName,id,preproc)
            if nargin < 4, id = shaderName; end
            assert(~isfield(obj.prog,id),[id ' is already initialized']);
            
            [fl,dl] = filelist(obj.shaderPath,[shaderName '.*.glsl']);
            types = extractBetween(fl,'.','.');
            gltypes = replace(types,obj.shaderTypes(:,1),obj.shaderTypes(:,2));
            ns = numel(gltypes);
            shaders = zeros(ns,1);
            for i=1:ns
                shaders(i) = gl.glCreateShader(gl.(gltypes{i}));
                str = fileread(fullfile(dl{i},fl{i}));
                if nargin > 4
                    k = find(str==newline,1);
                    str = insertAfter(str,k,[preproc newline]);
                end
                gl.glShaderSource(shaders(i),1,str,[]);
                gl.glCompileShader(shaders(i));

                isCompiled = javabuffer(int32(0));
                gl.glGetShaderiv(shaders(i),gl.GL_COMPILE_STATUS,isCompiled);
                if ~isCompiled.array
                    maxLength = javabuffer(int32(0));
                    gl.glGetShaderiv(shaders(i),gl.GL_INFO_LOG_LENGTH,maxLength);
                    n = maxLength.array;
                    str = javabuffer(zeros(n,1,'uint8'));
                    gl.glGetShaderInfoLog(shaders(i),n,maxLength,str);
                    error(['compile error on ' fl{i} newline char(str.array')])
                end

            end
            PROG = gl.glCreateProgram();
            
            for i=1:ns
                gl.glAttachShader(PROG,shaders(i));
            end
            
            gl.glLinkProgram(PROG);
            
            isLinked = javabuffer(int32(0));
            gl.glGetProgramiv(PROG,gl.GL_LINK_STATUS,isLinked);
            if ~isLinked.array
                maxLength = javabuffer(int32(0));
                gl.glGetProgramiv(PROG,gl.GL_INFO_LOG_LENGTH,maxLength);
                n = maxLength.array;
                str = javabuffer(zeros(n,1,'uint8'));
                gl.glGetProgramInfoLog(PROG,n,maxLength,str);
                error(['link error on ' id newline char(str.array')])
            end
            
            obj.prog.(id) = PROG;
            
            f = sprintf('x%i',PROG);
            obj.loc_cache.(f) = struct;
        end
        
        function PROG = Valid(obj,gl,id)
            if isnumeric(id), PROG = id; return, end
            if isfield(obj.prog,id)
                PROG = obj.prog.(id);
            else
                PROG = obj.Init(gl,id);
            end
        end
        
        function loc = GetUniLoc(obj,gl,id,name)
            PROG = obj.Valid(gl,id);
            obj.UseProg(gl,PROG);
            f = sprintf('x%i',PROG);
            if ~isfield(obj.loc_cache.(f),name)
                loc = gl.glGetUniformLocation(PROG,name);
                assert(loc >= 0, ['uniform location not found: ' name]);
                obj.loc_cache.(f).(name) = loc;
            end
            loc = obj.loc_cache.(f).(name);
        end
        
        function UseProg(obj,gl,prog)
            if prog == obj.lastProg, return, end
            gl.glUseProgram(prog);
            obj.lastProg = prog;
        end
        
        function SetInt1(obj,gl,prog,name,v)
            loc = obj.GetUniLoc(gl,prog,name);
            gl.glUniform1i(loc,v);
        end
        
        function SetFloat1(obj,gl,prog,name,v)
            loc = obj.GetUniLoc(gl,prog,name);
            gl.glUniform1f(loc,single(v));
        end

        function SetDouble1(obj,gl,prog,name,v)
            loc = obj.GetUniLoc(gl,prog,name);
            gl.glUniform1d(loc,v);
        end

        function SetDVec2(obj,gl,prog,name,v)
            loc = obj.GetUniLoc(gl,prog,name);
            gl.glUniform2d(loc,v(1),v(2));
        end
        
        function SetVec2(obj,gl,prog,name,v)
            loc = obj.GetUniLoc(gl,prog,name);
            v = single(v);
            gl.glUniform2f(loc,v(1),v(2));
        end
        
        function SetVec4(obj,gl,prog,name,v)
            loc = obj.GetUniLoc(gl,prog,name);
            gl.glUniform4f(loc,v(1),v(2),v(3),v(4));
        end
        
        function SetMat4(obj,gl,prog,name,v)
            loc = obj.GetUniLoc(gl,prog,name);
            v = javabuffer(v);
            gl.glUniformMatrix4fv(loc,1,gl.GL_FALSE,v);
        end
        
        function SetVec3(obj,gl,prog,name,v)
            loc = obj.GetUniLoc(gl,prog,name);
            n = size(v,1);
            v = javabuffer(v');
            gl.glUniform3fv(loc,n,v);
        end
        
        function SetProgUni(obj,gl,prog,S)
            fn = fieldnames(S);
            for i=1:numel(fn)
                prog = obj.Valid(gl,prog);
                fcn = ['Set' fn{i}];
                s = S.(fn{i});
                p = fieldnames(s);
                for j=1:numel(p)
                    obj.(fcn)(gl,prog,p{j},s.(p{j}))
                end
            end
        end
        
        function SetUni(obj,gl,S)
            fn = fieldnames(S);
            for i=1:numel(fn)
                obj.SetProgUni(gl,fn{i},S.(fn{i}));
            end
        end
        
    end
end


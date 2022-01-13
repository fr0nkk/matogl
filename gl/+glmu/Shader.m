classdef Shader < glmu.internal.Object
    
    properties
        type
        src = ''
    end
    
    methods
        function obj = Shader(type,source,varargin)
            % type = GL shader type
            % source = 'shader source'
            % optional preproc : char array to append up top to source
            obj.type = obj.Const(type);
            obj.id = obj.state.shader.New(obj.type);
            
            if nargin > 1
                obj.Source(source,varargin{:});
                obj.Compile();
            end
        end

        function Source(obj,source,preproc)
            % source = 'shader source'
            % optional preproc : char array to append up top to source
            if nargin > 2
                k = find(source==newline,1);
                source = insertAfter(source,k,[preproc newline]);
            end
            obj.src = source;
            obj.gl.glShaderSource(obj.id,1,source,[]);
        end

        function [v,b] = Get(obj,name)
            [v,b] = glmu.Get(obj.gl,@glGetShaderiv,{obj.id,obj.Const(name)});
        end

        function str = InfoLog(obj)
            [n,b] = obj.Get(obj.gl.GL_INFO_LOG_LENGTH);
            str = char(glmu.Get(obj.gl,@glGetShaderInfoLog,{obj.id,n,b},n,'uint8'))';
        end

        function Compile(obj)
            obj.gl.glCompileShader(obj.id);
            
            if ~obj.Get(obj.gl.GL_COMPILE_STATUS)
                log = obj.InfoLog();
                ME = MException('GL:SHADER:CompileFailed',log);
                throw(ME);
            end
        end

        function [uniName,type] = GetUniforms(obj)
            str = obj.src;
            str = regexprep(str,'/\*.*?\*/',''); % remove /* ... */
            str = regexprep(str,'//.*?\n',''); %remove // ...
            str = regexp(str,'uniform\s+\w+.*?\s+\w+.*?;','match')';
            str = cellfun(@(c) c(1:end-1),str,'uni',0);
            str = regexprep(str,'\[.*?\]','');
            str = regexprep(str,'=.*','');
            str = cellfun(@strsplit,str,'uni',0);
            str = str(~cellfun(@isempty,str));
            str = cellfun(@(c) c(2:3),str,'uni',0);
            str = vertcat(str{:});
            if isempty(str)
                type = {};
                uniName = {};
            else
                type = str(:,1);
                uniName = str(:,2);
            end
        end
    end
end


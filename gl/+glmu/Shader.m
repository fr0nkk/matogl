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

        function v = Get(obj,name)
            v = glmu.Get(obj.gl,@glGetShaderiv,{obj.id,obj.Const(name)});
        end

        function str = InfoLog(obj)
            n = obj.Get(obj.gl.GL_INFO_LOG_LENGTH);
            str = glmu.GetStr(obj.gl,@glGetShaderInfoLog,{obj.id},n,2,3,4);
        end

        function Compile(obj)
            obj.gl.glCompileShader(obj.id);
            
            if ~obj.Get(obj.gl.GL_COMPILE_STATUS)
                log = obj.InfoLog();
                ME = MException('GL:SHADER:CompileFailed',log);
                throw(ME);
            end
        end

        function delete(obj)
            obj.state.shader.DelayedDelete(obj.id);
        end
    end
end


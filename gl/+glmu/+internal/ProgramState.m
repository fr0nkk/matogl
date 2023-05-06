classdef ProgramState < glmu.internal.ObjectState
    
    properties
        newFcn = @glCreateProgram
        delFcn = @glDeleteProgram

        curSubroutine = struct

        stage
        stageStr
    end
    
    properties(Access = private)
        uniLookup
    end
    
    methods
        
        function id = New(obj)
            id = obj.Create();
        end

        function Use(obj,id)
            if obj.current == id, return, end
            obj.gl.glUseProgram(id);
            obj.curSubroutine = struct;
            obj.current = id;
        end

        function Delete(obj,id)
            obj.Delete1(id);
        end

        function SetSubroutineUniforms(obj,stage,value)
            str = obj.stageStr{obj.stage == stage};
            if isfield(obj.curSubroutine,str) && all(obj.curSubroutine.(str) == value)
                return
            end
            b = javabuffer(value,'int32');
            obj.gl.glUniformSubroutinesuiv(stage,b.capacity,b.p);
            obj.curSubroutine.(str) = value;
        end

        function [setFcnStr,matFcn] = ConvertType(obj,type,name)
            i = type == obj.uniLookup.glType;
            if ~any(i)
                error(['No type defined for ' name])
            end
            setFcnStr = obj.uniLookup.glFcn{i};
            matFcn = obj.uniLookup.matFcn{i};
        end

        function type = GetShaderType(obj,str)
            if ~iscell(str), str = {str}; end
            [tf,k] = ismember(str,obj.stageStr);
            if ~all(tf)
                error('unrecognized shader type: %s',strjoin(str(~tf)));
            end
            type = [obj.stage(k(tf))];
        end

    end
    methods(Access=protected)
        function Init(obj)
            obj.uniLookup = glmu.internal.BuildUniformLookup(obj.gl);

            T = {
                    %ext, GL_Type constant
                    'vert' 'GL_VERTEX_SHADER'
                    'tesc' 'GL_TESS_CONTROL_SHADER'
                    'tese' 'GL_TESS_EVALUATION_SHADER'
                    'geom' 'GL_GEOMETRY_SHADER'
                    'frag' 'GL_FRAGMENT_SHADER'
                    'comp' 'GL_COMPUTE_SHADER'                        
                };
            s = cellfun(@(c) GetType(obj.gl,c),T(:,2));
            tf = s ~= -1;
            obj.stage = s(tf);
            obj.stageStr = T(tf,1);
        end
    end
end

function t = GetType(gl,name)
    try
        t = gl.(name);
    catch
        t = -1;
    end
end



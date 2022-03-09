classdef SubroutineUniform < glmu.internal.Object
    
    properties
        progid
        stage
        subroutines = struct
        name
    end
    
    methods
        function obj = SubroutineUniform(progid,shaderType,name,index)
            obj.progid = progid;
            obj.stage = obj.Const(shaderType,1);
            obj.id = index;
            obj.name = name;
            n = obj.Get(obj.gl.GL_NUM_COMPATIBLE_SUBROUTINES);
            if n < 1, return, end
            s = obj.Get(obj.gl.GL_COMPATIBLE_SUBROUTINES,n);
            for i=1:numel(s)
                name = glmu.GetStr(obj.gl,@glGetActiveSubroutineName,{obj.progid,obj.stage,s(i)},100,4,5,6);
                obj.subroutines.(name) = s(i);
            end
        end

        function v = Get(obj,name,n)
            if nargin < 3, n = 1; end
            v = glmu.Get(obj.gl,@glGetActiveSubroutineUniformiv,{obj.progid,obj.stage,obj.id,obj.Const(name)},n);
        end

        function Set(obj,value)
            if ischar(value)
                value = obj.subroutines.(value);
            end
            obj.state.program.Use(obj.progid);
            cs = obj.state.program.currentSubroutine;
            if isfield(cs,obj.name) && cs.(obj.name) == value, return, end
            b = javabuffer(value,'int32');
            obj.gl.glUniformSubroutinesuiv(obj.stage,1,b.p);
            obj.state.program.currentSubroutine.(obj.name) = value;
        end

    end
end


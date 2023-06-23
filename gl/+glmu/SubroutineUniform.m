classdef SubroutineUniform < glmu.internal.Object
    
    properties
        progid
        stage
        subroutines = struct
        name
        index

        stageSubroutines
        current
    end
    
    methods
        function obj = SubroutineUniform(progid,shaderType,name,index)
            obj.progid = progid;
            obj.stage = obj.Const(shaderType,1);
            obj.index = index;
            obj.name = name;

            obj.id = obj.gl.glGetSubroutineUniformLocation(progid,shaderType,name);
            n = obj.Get(obj.gl.GL_NUM_COMPATIBLE_SUBROUTINES);
            if n < 1, return, end
            s = obj.Get(obj.gl.GL_COMPATIBLE_SUBROUTINES,n);
            for i=1:numel(s)
                name = glmu.GetStr(obj.gl,@glGetActiveSubroutineName,{obj.progid,obj.stage,s(i)},100,4,5,6);
                % obj.subroutines.(name) = obj.gl.glGetSubroutineIndex(progid,shaderType,name);
                obj.subroutines.(name) = s(i);
            end
            sz = obj.Get(obj.gl.GL_UNIFORM_SIZE);
            obj.current = repmat(s(1),1,sz);
            
        end

        function v = Get(obj,pname,n)
            if nargin < 3, n = 1; end
            v = glmu.Get(obj.gl,@glGetActiveSubroutineUniformiv,{obj.progid,obj.stage,obj.index,obj.Const(pname)},n);
        end

        function PreSet(obj,value)
            if ischar(value)
                value = obj.subroutines.(value);
            end
            obj.current = value;
        end

        function Set(obj,value)
            obj.PreSet(value);
            i = [obj.stageSubroutines.id]+1;
            vals = [obj.stageSubroutines.current];
            obj.state.program.Use(obj.progid);
            obj.state.program.SetSubroutineUniforms(obj.stage,vals(i))
        end

    end
end


classdef SubroutineUniform < glmu.internal.Object
    
    properties
        prog
        stage
        opts = struct
    end
    
    methods
        function obj = SubroutineUniform(program,shaderType,name,options)
            obj.prog = program;
            obj.stage = obj.Const(shaderType,1);
            obj.id = obj.gl.glGetSubroutineUniformLocation(obj.prog.id,obj.stage,name);
            
            for i=1:numel(options)
                obj.opts.(options{i}) = obj.gl.glGetSubroutineIndex(obj.prog.id, obj.stage, options{i});
            end
        end

        function Set(obj,name)
            obj.gl.glUniformSubroutinesuiv(obj.stage,1,obj.opts.(name));
        end

    end
end


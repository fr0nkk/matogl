classdef ProgramState < glmu.internal.ObjectState
    
    properties
        newFcn = @glCreateProgram
        delFcn = @glDeleteProgram
        currentSubroutine = ''
    end
    
    properties(Access = private)
        cache = struct
    end
    
    methods
        
        function id = New(obj)
            id = obj.Create();
        end

        function Use(obj,id)
            if obj.current == id, return, end
            obj.gl.glUseProgram(id);
            obj.currentSubroutine = '';
            obj.current = id;
        end

        function Delete(obj,id)
            obj.Delete1(id);
        end

        function [P,name] = GetCache(obj,name)
            [name,i] = ValidName(name);
            P = [];
            if isfield(obj.cache,name)
                Ps = obj.cache.(name);
                if numel(Ps) >= i
                    P = Ps{i};
                end
            end
        end

        function SetCache(obj,name,P)
            if isempty(name), return, end
            [name,i] = ValidName(name);
            obj.cache.(name){i} = P;
        end

        function EmptyCache(obj)
            obj.cache = [];
        end

    end
end

function [name,i] = ValidName(name)
    c = strsplit(name,'#');
    if numel(c) < 2 || isempty(c{2})
        i = 1;
    else
        i = str2double(c{2});
    end
    name = c{1};
end


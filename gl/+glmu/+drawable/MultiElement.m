classdef MultiElement < glmu.drawable.Element
    
    properties
        multi_uni
        countoffsets
        idUni
    end
    
    methods

        function DrawFcn(obj)
            obj.array.Bind;
            obj.element.Bind;
            for i=1:height(obj.countoffsets)
                if numel(obj.multi_uni) >= i
                    obj.program.SetUniforms(obj.multi_uni{i});
                end
                if ~isempty(obj.idUni)
                    obj.idUni.Set(i-1);
                end
                co = obj.countoffsets(i,:);
                obj.gl.glDrawElements(obj.primitive,co(1),obj.element.type,co(2)*4);
            end
        end

    end

end


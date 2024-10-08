classdef MultiElement < glmu.drawable.Element
    
    properties
        multi_uni
        countoffsets
        idUni
    end
    
    methods

        function DrawFcn(obj)
            obj.array.Bind;
            obj.element.buffer.Bind;
            for i=1:size(obj.countoffsets,1)
                if numel(obj.multi_uni) >= i
                    obj.program.SetUniforms(obj.multi_uni{i});
                end
                if ~isempty(obj.idUni)
                    obj.idUni.Set(i-1);
                end
                co = obj.countoffsets(i,:);
                bpe = obj.element.nbytes / obj.element.nbVertex;
                % obj.gl.glDrawElements(obj.primitive,co(1),obj.element.type,co(2)*obj.element.bytePerVertex);
                obj.gl.glDrawElements(obj.primitive,co(1),obj.element.type,co(2)*bpe+obj.element.offset);
            end
        end

    end

end


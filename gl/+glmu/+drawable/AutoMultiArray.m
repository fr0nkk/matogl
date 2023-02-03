classdef AutoMultiArray < glmu.internal.Drawable
    
    properties
        array
        primitive
        buffer
        data = {}
    end

    properties(Hidden)
        needRecalc
        offsets
        counts
    end
    
    methods
        function obj = AutoMultiArray(program,primitive,varargin)
            obj@glmu.internal.Drawable(program);
            obj.primitive = obj.Const(primitive,1);
            obj.array = glmu.ArrayFormat(varargin{:});
            nb = obj.array.nBuffers;
            obj.buffer = glmu.Buffer(obj.gl.GL_ARRAY_BUFFER,repmat({[]},1,nb));
            obj.needRecalc = false(1,nb);
        end

        function id = AddData(obj,data)
            i = numel(obj.id)+1;
            id = find(~ismember(1:i,obj.id),1);
            obj.id(i) = id;
            obj.EditData(id,data);
        end

        function EditData(obj,id,data)
            i = find(obj.id == id,1);
            for j=1:numel(data)
                if isempty(data{j}), continue, end
                obj.data{i,j} = javabuffer(data{j});
                obj.needRecalc(j) = 1;
            end
        end

        function data = GetData(obj,id)
            i = find(obj.id == id,1);
            data = cellfun(@array,obj.data(i,:),'uni',0);
        end

        function DeleteData(obj,id)
            i = find(obj.id == id,1);
            obj.id(i) = [];
            obj.data(i,:) = [];
            obj.needRecalc(:) = 1;
        end

        function RecalcBuffer(obj)
            if ~obj.needRecalc, return, end
            nb = obj.array.nBuffers;
            dat = repmat({[]},1,nb);
            for i=1:nb
                if ~obj.needRecalc(i), continue,end
                dat{i} = javabuffer.cat(2,obj.data{:,i});
            end
            obj.buffer.Edit(dat);
            c = cellfun(@(c) c.sz(2),obj.data(:,1));
%             c = cellfun(@(c) c.capacity,obj.data(:,1))./obj.buffer.sz(1,1);
            o = [0 ; cumsum(c(1:end-1))];
            obj.offsets = javabuffer(o,'int32');
            obj.counts = javabuffer(c,'int32');
            obj.needRecalc(:) = 0;
        end

        function DrawFcn(obj)
            if isempty(obj.id), return, end
            obj.array.Bind;
            obj.RecalcBuffer;
            B = obj.buffer;
            nb = obj.array.nBuffers;
            b = com.jogamp.common.nio.PointerBuffer.allocate(nb);
            obj.gl.glBindVertexBuffers(0,nb,B.id,0,b,B.bytePerVertex,0);
            obj.gl.glMultiDrawArrays(obj.primitive,obj.offsets.p,obj.counts.p,obj.counts.capacity);
        end
    end
end


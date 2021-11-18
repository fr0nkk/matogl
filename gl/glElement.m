classdef glElement < handle
    % helper class to abstract some opengl rendering pipeline

    properties
        show logical = true; % is false, Draw() is skipped for this element
        
        uni = struct; 
        % when an uni struct is defined, the uniform values will be updated
        % before every Draw()
        % .UniMat4.varName = value;
    end
    
    properties(Hidden)
        shaders
        SZ
        VBO int32
        VBOi int32
        DRAWTYPE int32
        VAO int32
        PROG int32
        TEX int32
        TEXTYPE int32
        bufferElemSz
        PRIM int32
        FBO int32
        RBO int32
        ni
    end
    
    methods
        function obj = glElement(gl,data,prog,shaders,primitiveType,drawType,normFlag,AttribIFlag)
            obj.shaders = shaders;
            % data must be in the size [nbValuesPerVertex x nbVertex] (example: [2 x 10] for 10 2d points)
            if ~iscell(data), data={data}; end
            data = data(:);
            nd = numel(data);
            
            % todo - use inputParser
            if nargin < 6, drawType = gl.GL_STATIC_DRAW; end
            if nargin < 7, normFlag = gl.GL_FALSE; end
            if nargin < 8, AttribIFlag = 0; end
            if numel(drawType) == 1 && nd > 1, drawType = repmat(drawType,nd,1); end
            if numel(normFlag) == 1 && nd > 1, normFlag = repmat(normFlag,nd,1); end
            if numel(AttribIFlag) == 1 && nd > 1, AttribIFlag = repmat(AttribIFlag,nd,1); end
            obj.DRAWTYPE = drawType;
            if ischar(primitiveType), primitiveType = gl.(primitiveType); end
            obj.PRIM = primitiveType;
            
            obj.PROG = shaders.Valid(gl,prog);
            sz = cellfun(@size,data,'uni',0);
            obj.SZ = vertcat(sz{:});
            assert(all(obj.SZ(:,2) == obj.SZ(1,2)),'all data must have same size in dim 2');
            
            obj.VBO = glGen(@gl.glGenBuffers,nd);
            obj.bufferElemSz = zeros(nd,1);
            obj.EditData(gl,data);
            mt = cellfun(@class,data,'uni',0);
            gltypes = upper(cellfun(@javatype,mt,'uni',0));
            
            i = startsWith(mt,'u');
            gltypes(i) = strcat('UNSIGNED_',gltypes(i));
            gltypes = strcat('GL_',gltypes);
            types = getfields(gl,2,gltypes{:});
            
            obj.VAO = glGen(@gl.glGenVertexArrays,1);
            gl.glBindVertexArray(obj.VAO);
            for i=1:numel(obj.VBO)
                gl.glBindBuffer(gl.GL_ARRAY_BUFFER,obj.VBO(i));
                if AttribIFlag(i)
                    gl.glVertexAttribIPointer(i-1,obj.SZ(i,1),types(i),0,0);
                else
                    gl.glVertexAttribPointer(i-1,obj.SZ(i,1),types(i),normFlag(i),0,0);
                end
                gl.glEnableVertexAttribArray(i-1);
            end
        end
        
        function AddTexture(obj,gl,i,texType,data,dataType,minFilter,magFilter,wrapS,wrapT)
            if nargin < 7, minFilter = gl.GL_LINEAR; end
            if nargin < 8, magFilter = gl.GL_LINEAR; end
            if nargin < 9, wrapS = gl.GL_REPEAT; end
            if nargin < 10, wrapT = gl.GL_REPEAT; end

            obj.TEX(i+1) = glGen(@gl.glGenTextures,1);
            obj.TEXTYPE(i+1) = texType;
            
            obj.EditTex(gl,i,data,dataType)
            
            gl.glTexParameteri(texType, gl.GL_TEXTURE_MIN_FILTER, minFilter);
            gl.glTexParameteri(texType, gl.GL_TEXTURE_MAG_FILTER, magFilter);
            gl.glTexParameteri(texType, gl.GL_TEXTURE_WRAP_S, wrapS);
            gl.glTexParameteri(texType, gl.GL_TEXTURE_WRAP_T, wrapT);
        end
        
        function EditData(obj,gl,data,subFlag,subOffset)
            if nargin < 4, subFlag = 0; end
            if nargin < 5, subOffset = 0; end
            nd = numel(data);
            for i=1:nd
                if isempty(data{i}), continue, end
                gl.glBindBuffer(gl.GL_ARRAY_BUFFER,obj.VBO(i));
                if isa(data{i},'java.nio.Buffer')
                    b = data{i};
                    if ~obj.bufferElemSz(i)
                        error('todo')
                        % find endsWith extractAfter javatype class(b)
                    end
                else
                    [b,obj.bufferElemSz(i)] = javabuffer(data{i});
                end
                
                szb = obj.bufferElemSz(i)*b.capacity;
                
                if subFlag
                    gl.glBufferSubData(gl.GL_ARRAY_BUFFER,subOffset*obj.bufferElemSz(i)*obj.SZ(i,1),szb,b);
                else
                    gl.glBufferData(gl.GL_ARRAY_BUFFER,szb,b,obj.DRAWTYPE(i));
                end
                if nargin < 5
                    obj.SZ(i,2) = b.capacity/obj.SZ(i,1);
                end
            end
        end
        
        function EditTex(obj,gl,i,data,dataType)
            gl.glActiveTexture(gl.GL_TEXTURE0+i);
            gl.glBindTexture(obj.TEXTYPE(i+1),obj.TEX(i+1));
            
            if ~isempty(data)
                if iscell(data)
                    gl.glTexImage2D(obj.TEXTYPE(i+1),data{:});
                else
                    if ischar(data)
                        data = imread(data);
                    end
                    if isfloat(data)
                        % float 0 to 1
                        data = uint8(data.*255);
                    end
                    sz = size(data);
                    data = flipud(data);
                    data = permute(data,ndims(data):-1:1);
                    bdata = javabuffer(data);
                    gl.glPixelStorei(gl.GL_UNPACK_ALIGNMENT, 1);
                    gl.glTexImage2D(obj.TEXTYPE(i+1), 0, dataType, sz(2), sz(1), 0, dataType, gl.GL_UNSIGNED_BYTE, bdata);
                end
            end
            
        end
        
        function SetIndex(obj,gl,idx)
            if isempty(obj.VBOi)
                obj.VBOi = glGen(@gl.glGenBuffers,1);
            end
            gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, obj.VBOi);
            [b,esz] = javabuffer(uint32(idx));
            obj.ni = numel(idx);
            gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, esz*obj.ni,b,gl.GL_STATIC_DRAW);
        end
        
        function Draw(obj,gl)
            if ~obj.show, return, end
            obj.shaders.UseProg(gl,obj.PROG);
            obj.shaders.SetProgUni(gl,obj.PROG,obj.uni)
            obj.SetTex(gl);
            gl.glBindVertexArray(obj.VAO);
            if isempty(obj.VBOi)
                gl.glDrawArrays(obj.PRIM,0,min(obj.SZ(:,2)));
            else
                gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, obj.VBOi);
                gl.glDrawElements(obj.PRIM,obj.ni,gl.GL_UNSIGNED_INT,0);
            end
        end
        
        function SetTex(obj,gl)
            for i=1:numel(obj.TEX)
                if obj.TEX(i)
                    gl.glActiveTexture(gl.GL_TEXTURE0+i-1);
                    gl.glBindTexture(obj.TEXTYPE(i),obj.TEX(i));
                end
            end
        end
        
        function EditRenderbuffer(obj,gl,type,sz)
            if isempty(obj.RBO)
                obj.RBO = glGen(@gl.glGenRenderbuffers,1);
            end
            gl.glBindRenderbuffer(gl.GL_RENDERBUFFER,obj.RBO);
%             gl.glRenderbufferStorageMultisample(gl.GL_RENDERBUFFER, 4, type, sz(1), sz(2)); % todo
            gl.glRenderbufferStorage(gl.GL_RENDERBUFFER,type,sz(1),sz(2));
        end
        
        function UseFramebuffer(obj,gl)
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER,obj.FBO);
        end
        
        function SetFramebuffer(obj,gl,rboType)
            if isempty(obj.FBO)
                obj.FBO = glGen(@gl.glGenFramebuffers,1);
            end
            obj.UseFramebuffer(gl);
            n = numel(obj.TEX);
            attachments = strcat('GL_COLOR_ATTACHMENT',arrayfun(@(a) sprintf('%i',a),0:n-1,'uni',0));
            for i=1:n
                gl.glFramebufferTexture2D(gl.GL_FRAMEBUFFER,gl.(attachments{i}),gl.GL_TEXTURE_2D,obj.TEX(i),0);
            end
            gl.glFramebufferRenderbuffer(gl.GL_FRAMEBUFFER,rboType,gl.GL_RENDERBUFFER,obj.RBO);
            
            b = javabuffer(int32(getfields(gl,2,attachments{:})));
            gl.glDrawBuffers(n, b);
            
            assert(gl.glCheckFramebufferStatus(gl.GL_FRAMEBUFFER) == gl.GL_FRAMEBUFFER_COMPLETE,'incomplete framebuffer');
        end
        
    end
end


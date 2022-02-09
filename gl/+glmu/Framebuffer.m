classdef Framebuffer < glmu.internal.Object
    
    properties
        target
        renderbuffer
    end
    
    methods
        function obj = Framebuffer(target,varargin)
            obj.target = obj.Const(target,1);
            obj.id = obj.state.framebuffer.New(1);
            obj.Edit(varargin{:});
        end

        function Edit(obj,renderbuffer,attachment)
            renderbuffer.SetSize([100 100]);
            obj.Bind;
            textures = renderbuffer.textures;
            n = numel(textures);
            attachments = strcat('GL_COLOR_ATTACHMENT',arrayfun(@(a) sprintf('%i',a),0:n-1,'uni',0));
            for i=1:n
                T = textures{i};
                obj.gl.glFramebufferTexture2D(obj.target,obj.Const(attachments{i},1),T.target,T.id,0);
            end
            obj.gl.glFramebufferRenderbuffer(obj.target,obj.Const(attachment,1),obj.gl.GL_RENDERBUFFER,renderbuffer.id);
            
            b = javabuffer(int32(obj.Const(attachments)));
            obj.gl.glDrawBuffers(n, b.p);
            
            assert(obj.gl.glCheckFramebufferStatus(obj.gl.GL_FRAMEBUFFER) == obj.gl.GL_FRAMEBUFFER_COMPLETE,'incomplete framebuffer');
            obj.renderbuffer = renderbuffer;
        end

        function Resize(obj,sz)
            obj.renderbuffer.SetSize(sz);
        end

        function Bind(obj)
            obj.state.framebuffer.Bind(obj.target,obj.id);
        end

        function Release(obj)
            obj.state.framebuffer.Bind(obj.target,0);
        end

        function delete(obj)
            obj.state.framebuffer.DelayedDelete(obj.id);
        end

    end
end


classdef Framebuffer < glmu.internal.Object
    
    properties
        target
        renderbuffer
        attachments

        currentRead = 1
        currentDraw = 1
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
            a = strcat('GL_COLOR_ATTACHMENT',arrayfun(@(a) sprintf('%i',a),0:n-1,'uni',0));
            obj.attachments = cellfun(@obj.Const,a);
            for i=1:n
                T = textures{i};
                obj.gl.glFramebufferTexture2D(obj.target,obj.attachments(i),T.target,T.id,0);
%                 glFramebufferTexture 2D ?
            end
            obj.gl.glFramebufferRenderbuffer(obj.target,obj.Const(attachment,1),obj.gl.GL_RENDERBUFFER,renderbuffer.id);
            
            assert(obj.gl.glCheckFramebufferStatus(obj.gl.GL_FRAMEBUFFER) == obj.gl.GL_FRAMEBUFFER_COMPLETE,'incomplete framebuffer');
            obj.renderbuffer = renderbuffer;
        end

        function Resize(obj,sz)
            obj.renderbuffer.SetSize(sz);
        end

        function DrawTo(obj,i)
            obj.state.framebuffer.Bind(obj.gl.GL_DRAW_FRAMEBUFFER,obj.id);

            n = numel(i);
            if n == numel(obj.currentDraw) && all(i == obj.currentDraw), return, end

            if n == 1
                obj.gl.glDrawBuffer(obj.attachments(i));
            else
                b = javabuffer(int32(obj.attachments(i)));
                obj.gl.glDrawBuffers(n, b.p);
            end
            obj.currentDraw = i;
        end

        function ReadFrom(obj,i)
            obj.state.framebuffer.Bind(obj.gl.GL_READ_FRAMEBUFFER,obj.id);
            if i == obj.currentRead, return, end
            obj.gl.glReadBuffer(obj.attachments(i));
            obj.currentRead = i;
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


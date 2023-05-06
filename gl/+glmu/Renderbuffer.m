classdef Renderbuffer < glmu.internal.Object
    
    properties
        internalFormat
        msaaSamples
        textures = {};
        texTypes
        texFormats
        texInternalformats
    end
    
    methods
        function obj = Renderbuffer(internalFormat,msaaSamples)
            if nargin < 2, msaaSamples = 0; end
            obj.msaaSamples = msaaSamples;
            obj.internalFormat = obj.Const(internalFormat);
            obj.id = obj.state.renderbuffer.New(1);
        end

        function AddTexture(obj,texture,texType,texFormat,texInternalFormat)
            i = numel(obj.textures)+1;
            obj.textures{i} = texture;
            obj.texTypes(i) = obj.Const(texType);
            obj.texFormats(i) = obj.Const(texFormat);
            obj.texInternalformats(i) = obj.Const(texInternalFormat);
        end

        function SetSize(obj,sz)
            obj.Bind;
            if obj.msaaSamples
                obj.gl.glRenderbufferStorageMultisample(obj.gl.GL_RENDERBUFFER,obj.msaaSamples,obj.internalFormat,sz(1),sz(2));
                for i=1:numel(obj.textures)
                    obj.textures{i}.EditMultisample(obj.msaaSamples,obj.texInternalformats(i),sz);
                end
            else
                obj.gl.glRenderbufferStorage(obj.gl.GL_RENDERBUFFER,obj.internalFormat,sz(1),sz(2));
                for i=1:numel(obj.textures)
                    obj.textures{i}.Edit({sz obj.texTypes(i)},obj.texFormats(i),0,obj.texInternalformats(i));
                end
            end
        end

        function Bind(obj)
            obj.state.renderbuffer.Bind(obj.id);
        end

        function delete(obj)
            obj.state.renderbuffer.DelayedDelete(obj.id);
        end

    end
end


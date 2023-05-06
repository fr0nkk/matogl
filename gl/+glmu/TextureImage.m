classdef TextureImage < glmu.internal.TextureBase
    
    properties
        texture

        level
        layered
        layer
        access
        format
    end

    properties(Dependent)
        unit
    end
    
    methods
        function obj = TextureImage(texture,level,layered,layer,access,format)
            obj.texture = texture;
            obj.level = level;
            obj.layered = layered;
            obj.layer = layer;
            obj.access = access;
            obj.format = format;
        end

        function Valid(obj)
            obj.state.texture.ImageUnit(obj.unit,obj.texture.id,obj.level,obj.layered,obj.layer,obj.access,obj.format);
        end

        function u = get.unit(obj)
            u = obj.texture.unit;
        end
    end
end


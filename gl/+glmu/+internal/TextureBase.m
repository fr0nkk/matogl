classdef(Abstract) TextureBase < glmu.internal.Object
    %TEXTUREBASE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Abstract)
        unit
    end
    
    methods(Abstract)
        Valid(obj)
    end
end


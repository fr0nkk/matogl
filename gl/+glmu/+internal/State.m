classdef State < handle
    
    properties
        buffer
        array
        shader
        program
        texture
        text
        framebuffer
        renderbuffer
        resourcesPath = ''
    end
    
    methods
        function obj = State
            obj.buffer = glmu.internal.BufferState;
            obj.array = glmu.internal.ArrayState;
            obj.shader = glmu.internal.ShaderState;
            obj.program = glmu.internal.ProgramState;
            obj.texture = glmu.internal.TextureState;
            obj.text = glmu.internal.TextState;
            obj.framebuffer = glmu.internal.FramebufferState;
            obj.renderbuffer = glmu.internal.RenderbufferState;
        end
    end
end


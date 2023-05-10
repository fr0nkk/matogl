classdef GLController < handle

    properties
        canvas
    end
    
    methods(Abstract)
        InitFcn(obj,varargin)
        UpdateFcn(obj,gl)
    end

    methods
        function setGLCanvas(obj,canvas)
            obj.canvas = canvas;
            canvas.ResizeFcn = @obj.ResizeFcn;
            canvas.UpdateFcn = @obj.InternalUpdate;
            canvas.InitFcn = @obj.InternalInit;
        end

        function InternalInit(obj,varargin)
            obj.InitFcn(varargin{:});
        end

        function InternalUpdate(obj,gl)
            obj.UpdateFcn(gl);
        end

        function ResizeFcn(obj,gl,sz)
            gl.glViewport(0,0,sz(1),sz(2));
        end

        function Update(obj)
            obj.canvas.Update;
        end
    end

end


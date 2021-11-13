classdef glCanvas < javacallbackmanager
    % Abstract class for creating OpenGL component
    % Set this class as a superclass for your opengl app
    % Define methods UpdateFcn and InitFcn in your opengl class
    properties
        frame % matlab jFrame
        gc % com.jogamp.opengl.awt.GLCanvas
        glStop logical = 0;
    end
    
    properties(Access=private)
        context
    end
    
    methods(Sealed=true)
        function Init(obj, frame, glProfile, multisample, varargin)
            import com.jogamp.opengl.*;
            if nargin < 4, multisample = 0; end
            obj.frame = frame;
            gp = GLProfile.get(glProfile);
            cap = GLCapabilities(gp);
            if multisample
                cap.setSampleBuffers(1);
                cap.setNumSamples(multisample);
            end
            obj.gc = awt.GLCanvas(cap);
            
            frame.jf.add(obj.gc);
            frame.jf.show();
            obj.gc.setAutoSwapBufferMode(false);
            obj.gc.display();
            
            obj.populateCallbacks(obj.gc);
            frame.setCallback('WindowClosed',@(~,~) obj.delete);
            obj.glFcn(@obj.InitFcn,varargin{:});
        end
        
        function varargout = glFcn(obj,fcn,varargin)
            % to call a function which needs d and gl
            % "out = obj.glFcn(@myFcn,arg1,arg2)" will be called as "out = myFcn(d,gl,arg1,arg2)"
            if obj.glStop, return, end
            [d,gl,temp] = obj.getContext; %#ok<ASGLU> 
            [varargout{1:nargout}] = fcn(d,gl,varargin{:});
            if obj.glStop, return, end
            err = gl.glGetError();
            if err
                warning(['GL Error 0x' dec2hex(err,4)]);
            end
        end

        function [d,gl,temp] = getContext(obj)
            obj.context = obj.gc.getContext;
            if ~obj.context.isCurrent
                obj.context.makeCurrent;
            end
            temp = onCleanup(@() obj.releaseContext);
            gl = obj.context.getCurrentGL;
            d = obj.context.getGLDrawable;
        end
        
        function releaseContext(obj)
            if obj.context.isCurrent
                obj.context.release;
            end
        end
        
        function [d,gl] = glDrawnow(obj)
            % necessary if a callback needs to make another context current
            obj.releaseContext;
            drawnow
            if obj.glStop, d=[]; gl=[]; return, end
            % continue with our context
            obj.context.makeCurrent;
            gl = obj.context.getCurrentGL;
            d = obj.context.getGLDrawable;
        end
        
        function Update(obj)
            obj.glFcn(@obj.UpdateFcn);
        end
    end
    
    methods
        
        function delete(obj)
            obj.glStop = 1;
            obj.rmCallback;
            delete(obj.frame);
        end
        
    end
    
    methods(Abstract)
        % d is the GLDrawable
        % gl is the GL object
        UpdateFcn(obj,d,gl)
        InitFcn(obj,d,gl)
    end
end


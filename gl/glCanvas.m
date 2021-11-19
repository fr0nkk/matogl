classdef glCanvas < javacallbackmanager
    % Abstract class for creating OpenGL component
    % Set this class as a superclass for your opengl render class
    % Define those methods in your class:
    % InitFcn(obj,d,gl,varargin)
    % UpdateFcn(obj,d,gl)
    % ResizeFcn(obj,d,gl)
    
    properties
        frame % jFrame
        gc % com.jogamp.opengl.awt.GLCanvas
        glStop logical = 0;
        autoCheckError logical = 1;
        updateNeeded logical = 0;
        resizeNeeded logical = 1;
        updating logical = 0;
    end
    
    properties(Access=private)
        context
    end
    
    methods(Sealed=true)
        function Init(obj, frame, glProfile, multisample, varargin)
            % frame is a jFrame(). Included in /utils/
            % glProfile is a char array of the requested GL profile. Example: 'GL3'
            % multisample is the number of samples for MSAA (multisample anti-aliasing)
            %  a value of 0 deactivates MSAA
            %  (default to 0 if not set)
            % varargin are arguments you want to pass to InitFcn(obj,d,gl,varargin)

            assert(isa(frame,'jFrame'),'frame argument must be jFrame()');
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
            obj.setMethodCallback('ComponentResized');
            obj.Update;
        end
        
        function varargout = glFcn(obj,fcn,varargin)
            % to call a function which needs d and gl
            % "out = obj.glFcn(@myFcn,arg1,arg2)" will be called as "out = myFcn(d,gl,arg1,arg2)"
            if obj.glStop, return, end
            [d,gl,temp] = obj.getContext; %#ok<ASGLU> 
            [varargout{1:nargout}] = fcn(d,gl,varargin{:});
            if obj.glStop, return, end
            if obj.autoCheckError, obj.CheckError(gl); end
        end

        function [d,gl,temp] = getContext(obj)
            % always request temp. This ensures that the context is
            % released when temp is cleared.
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
            % Java events (like mouse drag) can happen so quickly that the
            % update rate doesn't follow. This strategy skips updates that
            % happen before a previous update had time to finish while
            % ensuring that the last update requested is always run.
            obj.updateNeeded = 1;
            if obj.updating || obj.glStop
                return
            end
            obj.updating = 1; temp1 = onCleanup(@() obj.EndUpdate);
            [d,gl,temp2] = getContext(obj); %#ok<ASGLU> temp2 is onCleanup()
            while obj.updateNeeded
                if obj.resizeNeeded
                    obj.resizeNeeded = 0;
                    obj.ResizeFcn(d,gl);
                end
                obj.updateNeeded = 0;
                obj.UpdateFcn(d,gl);
                [d,gl] = obj.glDrawnow;
                if obj.glStop, return, end
            end
            if obj.autoCheckError, obj.CheckError(gl); end
        end

        function EndUpdate(obj)
            obj.updating = 0;
        end

        function ComponentResized(obj,~,~)
            obj.resizeNeeded = 1;
            obj.Update;
        end
    end
    
    methods
        
        function delete(obj)
            obj.glStop = 1;
            obj.rmCallback;
            delete(obj.frame);
        end
        
    end

    methods(Static)
        function CheckError(gl)
            err = gl.glGetError();
            while err > 0
                % make text orange
                % https://undocumentedmatlab.com/articles/another-command-window-text-color-hack
                disp(['[' 8 'GL Error 0x' dec2hex(err,4) ']' 8]);
                err = gl.glGetError();
            end
        end
    end
    
    methods(Abstract)
        % d is the GLDrawable
        % gl is the GL object
        InitFcn(obj,d,gl,varargin)
        UpdateFcn(obj,d,gl)
        ResizeFcn(obj,d,gl);
    end
end


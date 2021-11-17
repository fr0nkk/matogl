classdef glMandelbrot < glCanvas
    
    properties
        sz = [600 450];
        shaders
        
        M % glElement
        
        click = struct('xy',[0 0],'z',[0 0]);
        cmap single = [jet(128) ; flipud(jet(128))];
        
        f1 % Float1 or Double1
        f2 % Vec2 or DVec2
    end
    
    methods
        function obj = glMandelbrot(maxIter,doublePrecisionFlag)
            if nargin < 1, maxIter = 100; end
            if nargin < 2, doublePrecisionFlag = 0; end
            frame = jFrame('GL Mandelbrot',obj.sz);

            if doublePrecisionFlag
                target = 'GL4';
            else
                target = 'GL3';
            end
            
            obj.Init(frame,target,0,maxIter,doublePrecisionFlag);

            obj.setMethodCallback('MousePressed');
            obj.setMethodCallback('MouseDragged');
            obj.setMethodCallback('MouseWheelMoved');
        end
        
        function InitFcn(obj,~,gl,maxIter,deep)
            obj.shaders = glShaders(fullfile(fileparts(mfilename('fullpath')),'shaders'));
            
            if deep
                preproc = '#define DEEP';
                obj.f1 = 'Double1';
                obj.f2 = 'DVec2';
            else
                preproc = '';
                obj.f1 = 'Float1';
                obj.f2 = 'Vec2';
            end
            
            obj.shaders.Init(gl,'mandelbrot','mb',preproc);

            vert = single([-1 -1;1 -1;-1 1;1 1]');
            obj.M = glElement(gl,{vert},'mb',obj.shaders,gl.GL_TRIANGLE_STRIP);
            
            obj.M.uni.(obj.f2).offset = [-0.5 0];
            obj.M.uni.(obj.f1).scale = 1.6;

            obj.shaders.SetVec3(gl,'mb','cmap',obj.cmap);
            obj.shaders.SetInt1(gl,'mb','maxIter',maxIter);
            gl.glClearColor(0,0,0,0);
        end
        
        function UpdateFcn(obj,d,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            obj.M.Draw(gl);
            d.swapBuffers;
        end
        
        function ResizeFcn(obj,~,gl)
            obj.sz = [obj.gc.getWidth obj.gc.getHeight];
            obj.shaders.(['Set' obj.f2])(gl,'mb','ratio',obj.sz/mean(obj.sz));
            gl.glViewport(0,0,obj.sz(1),obj.sz(2));
        end

        function MousePressed(obj,~,evt)
            obj.click.xy = [-evt.getX evt.getY];
            obj.click.z = obj.M.uni.(obj.f2).offset;
        end
        
        function MouseDragged(obj,~,evt)
            dxy = [-evt.getX evt.getY] - obj.click.xy;
            s = obj.M.uni.(obj.f1).scale;
            dOffset = dxy ./ mean(obj.sz) * 2 * s;
            obj.M.uni.(obj.f2).offset = obj.click.z + dOffset;
            obj.Update;
        end
        
        function MouseWheelMoved(obj,~,evt)
            z = evt.getUnitsToScroll / 30;
            s = obj.M.uni.(obj.f1).scale;
            dxy = [evt.getX evt.getY] ./ obj.sz * 2 - 1; % scale to -1:1
            ratio = obj.sz/mean(obj.sz);
            obj.M.uni.(obj.f1).scale = (1+z) .* s;
            obj.M.uni.(obj.f2).offset = obj.M.uni.(obj.f2).offset + dxy.*[-1 1].* ratio * z * s;
            obj.Update;
        end

    end
    
end


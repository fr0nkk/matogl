classdef glMandelbrot < glCanvas
    
    properties
        sz = [600 450];

        prog
        M % glmu.drawable.Array
        
        click = struct('xy',[0 0],'z',[0 0]);
        cmap single = [jet(128) ; flipud(jet(128))];
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
            glmu.SetResourcesPath(fileparts(mfilename('fullpath')));
            
            if deep
                preproc = '#define DEEP';
            else
                preproc = '';
            end
            obj.prog = glmu.Program('mandelbrot',preproc);

            vert = single([-1 -1;1 -1;-1 1;1 1]');
            obj.M = glmu.drawable.Array(obj.prog,gl.GL_TRIANGLE_STRIP,{vert});
            
            obj.M.uni.offset = [-0.5 0];
            obj.M.uni.scale = 1.6;
            
            obj.prog.uniforms.cmap.Set(obj.cmap');
            obj.prog.uniforms.maxIter.Set(maxIter);
            gl.glClearColor(0,0,0,0);
        end
        
        function UpdateFcn(obj,d,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            obj.M.Draw();
            d.swapBuffers;
        end
        
        function ResizeFcn(obj,~,gl)
            obj.sz = [obj.java.getWidth obj.java.getHeight];
            obj.prog.uniforms.ratio.Set(obj.sz/mean(obj.sz));
            gl.glViewport(0,0,obj.sz(1),obj.sz(2));
        end

        function MousePressed(obj,~,evt)
            obj.click.xy = [-evt.getX evt.getY];
            obj.click.z = obj.M.uni.offset;
        end
        
        function MouseDragged(obj,~,evt)
            dxy = [-evt.getX evt.getY] - obj.click.xy;
            s = obj.M.uni.scale;
            dOffset = dxy ./ mean(obj.sz) * 2 * s;
            obj.M.uni.offset = obj.click.z + dOffset;
            obj.Update;
        end
        
        function MouseWheelMoved(obj,~,evt)
            z = evt.getUnitsToScroll / 30;
            s = obj.M.uni.scale;
            dxy = [evt.getX evt.getY] ./ obj.sz * 2 - 1; % scale to -1:1
            ratio = obj.sz/mean(obj.sz);
            obj.M.uni.scale = (1+z) .* s;
            obj.M.uni.offset = obj.M.uni.offset + dxy.*[-1 1].* ratio * z * s;
            obj.Update;
        end

    end
    
end


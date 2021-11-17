classdef glMandelbrot < glCanvas
    
    properties
        sz = [600 450];
        shaders
        
        M % glElement
        
        click = struct('xy',[0 0],'z',[0 0]);
        cmap single = jet(256);
    end
    
    methods
        function obj = glMandelbrot()
            frame = jFrame('GL Mandelbrot',obj.sz);
            
            obj.Init(frame,'GL3',0);

            obj.setMethodCallback('MousePressed');
            obj.setMethodCallback('MouseDragged');
            obj.setMethodCallback('MouseWheelMoved');
        end
        
        function InitFcn(obj,~,gl)
            obj.shaders = glShaders(fullfile(fileparts(mfilename('fullpath')),'shaders'));
            
            vert = single([-1 -1;1 -1;-1 1;1 1]');
            obj.M = glElement(gl,{vert},'mandelbrot',obj.shaders,gl.GL_TRIANGLE_STRIP);
            obj.M.uni.Vec2.offset = single([-0.5 0]);
            obj.M.uni.Float1.scale = single(1.6);

            obj.shaders.SetVec3(gl,'mandelbrot','cmap',obj.cmap);
            gl.glClearColor(0,0,0,0);
        end
        
        function UpdateFcn(obj,d,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            obj.M.Draw(gl);
            d.swapBuffers;
        end
        
        function ResizeFcn(obj,~,gl)
            obj.sz = [obj.gc.getWidth obj.gc.getHeight];
            obj.shaders.SetVec2(gl,'mandelbrot','ratio',single(obj.sz/mean(obj.sz)));
            gl.glViewport(0,0,obj.sz(1),obj.sz(2));
        end

        function MousePressed(obj,~,evt)
            obj.click.xy = [-evt.getX evt.getY];
            obj.click.z = obj.M.uni.Vec2.offset;
        end
        
        function MouseDragged(obj,~,evt)
            dxy = [-evt.getX evt.getY] - obj.click.xy;
            s = obj.M.uni.Float1.scale;
            dOffset = dxy ./ mean(obj.sz) * 2 * s;
            obj.M.uni.Vec2.offset = obj.click.z + dOffset;
            obj.Update;
        end
        
        function MouseWheelMoved(obj,~,evt)
            z = evt.getUnitsToScroll / 30;
            s = obj.M.uni.Float1.scale;
            dxy = [evt.getX evt.getY] ./ obj.sz * 2 - 1; % scale to -1:1
            ratio = obj.sz/mean(obj.sz);

            obj.M.uni.Float1.scale = (1+z) .* s;
            obj.M.uni.Vec2.offset = obj.M.uni.Vec2.offset + dxy.*[-1 1].* ratio * z * s;

            a = 20*log2(50/obj.M.uni.Float1.scale);
            obj.M.uni.Int1.maxIter = int32(a);

            obj.Update;
        end
    end
end


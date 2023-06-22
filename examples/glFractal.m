classdef glFractal < glmu.GLController
    
    properties
        sz = [600 450];
        drawable % glmu.drawable.Array
        click = struct('xy',[0 0],'z',[0 0]);
    end

    properties(SetObservable)
        cmap single = [jet(128) ; flipud(jet(128))];
        maxIter int32 = 100;
        fractal char = 'mandelbrot'
        seed double = [0 0];
    end
    
    methods
        function obj = glFractal(fractal,doublePrecisionFlag)

            if nargin < 1, fractal = 'mandelbrot'; end
            obj.fractal = fractal;

            if strcmp(obj.fractal,'julia')
                obj.seed = [-0.79,0.15];
            else
                obj.seed = [0,0];
            end
            if nargin < 2, doublePrecisionFlag = 0; end

            if doublePrecisionFlag
                obj.maxIter = 1000;
                target = 'GL4';
            else
                obj.maxIter = 100;
                target = 'GL3';
            end

            frame = JFrame('glFractal',obj.sz);
            canvas = frame.add(GLCanvas(target,0,obj));
            canvas.Init(doublePrecisionFlag);

            canvas.setCallback('MousePressed',@obj.MousePressed);
            canvas.setCallback('MouseDragged',@obj.MouseDragged);
            canvas.setCallback('MouseWheelMoved',@obj.MouseWheelMoved);

            addlistener(obj,{'cmap','maxIter','fractal','seed'},'PostSet',@obj.PropUpdate);
        end
        
        function InitFcn(obj,gl,deep)
            if deep
                preproc = '#define DEEP';
            else
                preproc = '';
            end
            prog = example_prog('fractal',preproc);

            vert = single([-1 -1;1 -1;-1 1;1 1]');
            obj.drawable = glmu.drawable.Array(prog,gl.GL_TRIANGLE_STRIP,{vert});
            
            obj.drawable.uni.offset = [0 0];
            obj.drawable.uni.scale = 1.6;

            obj.drawable.uni.cmap = obj.cmap';
            obj.drawable.uni.maxIter = obj.maxIter;
            obj.drawable.uni.fractal = obj.fractal;
            obj.drawable.uni.seed = obj.seed;
            gl.glClearColor(0,0,0,0);
        end
        
        function UpdateFcn(obj,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);
            obj.drawable.Draw();
        end
        
        function ResizeFcn(obj,gl,sz)
            obj.sz = sz;
            obj.drawable.uni.ratio = sz/mean(sz);
            gl.glViewport(0,0,sz(1),sz(2));
        end

        function MousePressed(obj,~,evt)
            obj.click.xy = [-evt.getX evt.getY];
            obj.click.z = obj.drawable.uni.offset;
        end
        
        function MouseDragged(obj,~,evt)
            dxy = [-evt.getX evt.getY] - obj.click.xy;
            s = obj.drawable.uni.scale;
            dOffset = dxy ./ mean(obj.sz) * 2 * s;
            obj.drawable.uni.offset = obj.click.z + dOffset;
            obj.Update;
        end
        
        function MouseWheelMoved(obj,~,evt)
            z = evt.getUnitsToScroll / 30;
            s = obj.drawable.uni.scale;
            dxy = [evt.getX evt.getY] ./ obj.sz * 2 - 1; % scale to -1:1
            ratio = obj.sz/mean(obj.sz);
            obj.drawable.uni.scale = (1+z) .* s;
            obj.drawable.uni.offset = obj.drawable.uni.offset + dxy.*[-1 1].* ratio * z * s;
            obj.Update;
        end

        function set.fractal(obj,str)
            if ~ismember(str,{'julia','mandelbrot'})
                error('fractal must be ''mandelbrot'' or ''julia''');
            end
            obj.fractal = str;
        end

        function PropUpdate(obj,src,evt)
            prop = src.Name;
            value = obj.(prop);
            if strcmp(prop,'cmap')
                value = value';
            end
            obj.drawable.uni.(prop) = value;
            obj.Update;
        end

    end
    
end


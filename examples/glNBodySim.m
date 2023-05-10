classdef glNBodySim < glmu.GLController
    
    properties
        gravity
        attractors
        
        workgroupsize = 32
        nParticles = 64
        maxWeight = 100000;
        minWeight = 1000;
        G = 0.1

        t
    end
    
    methods
        function obj = glNBodySim()

            frame = JFrame('glNBodySim',[600 450]);
            canvas = frame.add(GLCanvas('GL3',0,obj));
            obj.t = tic;
            canvas.Init;

            while 1
                try
                    obj.Update;
                catch
                    break
                end
            end
        end
        
        function InitFcn(obj,gl)
            gl.glClearColor(0,0,0,1);
            preproc = sprintf('#define WORKGROUPSIZE %i',obj.workgroupsize);
            obj.gravity = example_prog('gravity',preproc);
            obj.gravity.uniforms.G.Set(obj.G);
            
            pos = randn(obj.nParticles,3,'single');
            pos = pos.*[100 100 0];
            pos(:,4) = rand(size(pos,1),1).*(obj.maxWeight - obj.minWeight)+obj.minWeight;

            vel = pos.*0;
            a = atan2(pos(:,2),pos(:,1))+pi/2;
            vel(:,1:2) = [cos(a) sin(a)].*10;

            buffer = glmu.Buffer(gl.GL_SHADER_STORAGE_BUFFER,{pos',vel'});
            
            obj.attractors = glmu.drawable.Array(example_prog('particle'),gl.GL_POINTS,buffer);
            obj.attractors.program.uniforms.maxWeight.Set(obj.maxWeight);

            buffer.BindBase(0,1);
            buffer.BindBase(1,2);

        end
        
        function UpdateFcn(obj,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);

            obj.gravity.uniforms.dt.Set(toc(obj.t));
            obj.t = tic;
            obj.gravity.Dispatch(ceil(obj.nParticles/obj.workgroupsize),1,1);
            gl.glMemoryBarrier(gl.GL_SHADER_STORAGE_BARRIER_BIT);
            
            obj.attractors.Draw;
        end
        
        function ResizeFcn(obj,gl,sz)
            gl.glViewport(0,0,sz(1),sz(2));
            obj.attractors.program.uniforms.projection.Set(MProj3D('O',[sz -1000 1000]));
        end
    end
end


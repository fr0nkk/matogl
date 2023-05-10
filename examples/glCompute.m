classdef glCompute < glmu.GLController
    % work in progress
    %
    % Enables computing on the GPU for simple functions operating on large
    % amount of data.
    %
    % See glComputeUsageExample
    %
    % todo: make easier to use
    properties
        shadersPath
        progs
        groupSz
        stateString
        buffer
    end
    
    methods
        function obj = glCompute(shadersPath)
            obj.shadersPath = shadersPath;

            frame = JFrame('glCompute',[300 100]);
            canvas = frame.add(GLCanvas('GL3',4,obj));
            canvas.Init;
            frame.setCallback('WindowClosing',@(~,~)obj.delete)
        end

        function InitFcn(obj,gl)
            gl.glClearColor(1,1,1,0);
            obj.stateString = glmu.drawable.Text('glCompute',20,[0 0 0 1]);%,eye(4),MTrans3D([-150 -100 0]));
            % obj.state = glmu.Text('arial','glCompute',20,[0 0 0 1]);
            N = 8;
            B = cell(1,N);
            obj.buffer = glmu.Buffer(gl.GL_SHADER_STORAGE_BUFFER,B);
            for i=1:N
                obj.buffer.BindBase(i-1,i)
            end
        end

        function InitCompute(obj,prog,alias,workgroupsize)
            % todo add iBufferIn and iBufferOut arguments to simplify calling
            [gl,temp] = obj.canvas.getContext;
            preproc = sprintf('#define WORKGROUPSIZE %i',workgroupsize);
            obj.progs.(alias) = glmu.Program(fullfile(obj.shadersPath,prog),preproc);
            obj.groupSz.(alias) = workgroupsize;
        end

        function SetConstants(obj,alias,s)
            [gl,temp] = obj.canvas.getContext;
            obj.progs.(alias).SetUniforms(s);
        end

        function SetBuffer(obj,B)
            [gl,temp] = obj.canvas.getContext;
            obj.buffer.Edit(B,gl.GL_DYNAMIC_DRAW);
        end

        function GetBuffer(obj,iBuffer,jb)
            [gl,temp] = obj.canvas.getContext;
            obj.buffer.Bind(iBuffer);
            b = gl.glMapBuffer(obj.buffer.target,gl.GL_READ_ONLY);
            jb.p.put(b.(['as' jb.javaType 'Buffer']));
            gl.glUnmapBuffer(obj.buffer.target);
            jb.p.rewind;
        end

        function Run(obj,alias,nbElems)
            [gl,temp] = obj.canvas.getContext;
            n = ceil(nbElems / obj.groupSz.(alias));
            obj.progs.(alias).Dispatch(n,1,1);
            gl.glMemoryBarrier(bitor(gl.GL_SHADER_STORAGE_BARRIER_BIT,gl.GL_BUFFER_UPDATE_BARRIER_BIT));
        end

        function UpdateFcn(obj,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);

            obj.stateString.Draw;
        end

        function ResizeFcn(obj,gl,sz)
            gl.glViewport(0,0,sz(1),sz(2));
            obj.stateString.proj = MProj3D('O',[sz -1 1]);
            obj.stateString.model = MTrans3D([-sz(1)./2+5 -10 0]);
        end
        
    end
end


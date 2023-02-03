classdef glCompute < glCanvas
    % work in progress
    %
    % Enables computing on the GPU for simple functions operating on large
    % amount of data.
    %
    % See glComputeUsageExample
    %
    % todo: make easier to use
    properties
        progs
        groupSz
        state
        buffer
    end
    
    methods
        function obj = glCompute(glslCompPath)
            obj.Init(jFrame('glCompute',[300 100]),'GL4',4,glslCompPath);
        end

        function InitFcn(obj,d,gl,glslCompPath)
            glmu.SetResourcesPath(glslCompPath);
            gl.glClearColor(1,1,1,0);
            obj.state = glmu.Text('arial','glCompute',20,[0 0 0 1]);
            N = 8;
            B = cell(1,N);
            obj.buffer = glmu.Buffer(gl.GL_SHADER_STORAGE_BUFFER,B);
            for i=1:N
                obj.buffer.BindBase(i-1,i)
            end
        end

        function InitCompute(obj,prog,alias,workgroupsize)
            % todo add iBufferIn and iBufferOut arguments to simplify calling
            [d,gl,temp] = obj.getContext;
            preproc = sprintf('#define WORKGROUPSIZE %i',workgroupsize);
            obj.progs.(alias) = glmu.Program(prog,preproc);
            obj.groupSz.(alias) = workgroupsize;
        end

        function SetConstants(obj,alias,s)
            [d,gl,temp] = obj.getContext;
            obj.progs.(alias).SetUniforms(s);
        end

        function SetBuffer(obj,B)
            [d,gl,temp] = obj.getContext;
            obj.buffer.Edit(B,gl.GL_DYNAMIC_DRAW);
        end

        function GetBuffer(obj,iBuffer,jb)
            [d,gl,temp] = obj.getContext;
            obj.buffer.Bind(iBuffer);
            b = gl.glMapBuffer(obj.buffer.target,gl.GL_READ_ONLY);
            jb.p.put(b.(['as' jb.javaType 'Buffer']));
            gl.glUnmapBuffer(obj.buffer.target);
            jb.p.rewind;
        end

        function Run(obj,alias,nbElems)
            [d,gl,temp] = obj.getContext;
            n = ceil(nbElems / obj.groupSz.(alias));
            obj.progs.(alias).Dispatch(n,1,1);
            gl.glMemoryBarrier(bitor(gl.GL_SHADER_STORAGE_BARRIER_BIT,gl.GL_BUFFER_UPDATE_BARRIER_BIT));
        end

        function UpdateFcn(obj,d,gl)
            gl.glClear(gl.GL_COLOR_BUFFER_BIT);

            obj.state.Draw;

            d.swapBuffers
        end

        function ResizeFcn(obj,d,gl)
            sz = [obj.java.getWidth,obj.java.getHeight];
            gl.glViewport(0,0,sz(1),sz(2));
            obj.state.projection = MProj3D('O',[sz -1 1]);
            obj.state.model{1} = MTrans3D([-sz(1)./2+5 -10 0]);
        end
        
    end
end


function glComputeUsageExample

N = 1e5;
input = rand(4,N,'single') + 1;

for i=1:3

    tic
    ml_out = myFunction(input);
    ml_time = toc;
    fprintf('matlab time: %.6f\n',ml_time);
    
    tic
    gl_out = myFunction_gl(input);
    gl_time = toc;
    fprintf('gl time: %.6f\n',gl_time);

end

fprintf('speedup: x%.2f\n', ml_time / gl_time);

assert(all(abs(ml_out(:) - gl_out(:)) < 0.01))

end

function out = myFunction_gl(in)
    persistent glComp outbuffer
    if isempty(glComp) || ~isvalid(glComp)
        thisPath = fileparts(mfilename('fullpath'));
        shadersPath = fullfile(thisPath,'shaders');
        glComp = glCompute(shadersPath);
        glComp.InitCompute('example_glcompute','myComputeAlias',1024);
        const = struct('const1',1);
        glComp.SetConstants('myComputeAlias',const);
        outbuffer = javabuffer(in);
        glComp.SetBuffer({[] outbuffer});
    end

    glComp.SetBuffer({in});
    glComp.Run('myComputeAlias',size(in,2));
    glComp.GetBuffer(2,outbuffer);
    out = outbuffer.array;
end

function out = myFunction(in)
    out = in;
    for i=1:100
        out = out + sqrt(out) + sin(out) + cos(out) + 1;
    end
end


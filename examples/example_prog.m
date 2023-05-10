function prog = example_prog(shaderName,varargin)

shadersDir = fullfile(fileparts(mfilename('fullpath')),'shaders');
shaderFullpath = fullfile(shadersDir,shaderName);

prog = glmu.Program(shaderFullpath,varargin{:});

end

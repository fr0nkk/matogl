function matogl_paths(addFlag)

if nargin < 1, addFlag = true; end

pathList = {
    'gl'
    'examples'
    'utils'
    };

if addFlag
    func = @addpath;
else
    func = @rmpath;
end

rootDir = fileparts(mfilename('fullpath'));

fullPathList = fullfile(rootDir,pathList);

cellfun(func,fullPathList);

end


function out = matogl_paths(addFlag)
% add or remove paths for matogl

if nargin < 1, addFlag = true; end

pathList = {
    'gl'
    'examples'
    'utils'
    fullfile('utils','java')
    };

if addFlag
    func = @addpath;
else
    func = @rmpath;
end

rootDir = fileparts(mfilename('fullpath'));

fullPathList = fullfile(rootDir,pathList);

cellfun(func,fullPathList);

if nargout >= 1, out = fullPathList; end

end


function [filename,source,fullname] = filelist(varargin)
% retourne la liste de fichiers. s'emploie comme fullfile()
% accepte les wildcard (*)

fullPath = fullfile(varargin{:});

if iscell(fullPath)
    [filename,source] = cellfun(@filelist,fullPath,'uni',0);
    filename = vertcat(filename{:});
    source = vertcat(source{:});
    return
end

d = dir(fullPath);
idx = ~[d.isdir];
filename={d(idx).name}';
source={d(idx).folder}';

if nargout == 3
    fullname = fullfile(source,filename);
end
end


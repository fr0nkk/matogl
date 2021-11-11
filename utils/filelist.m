function [filename,dirname,fullname] = filelist(varargin)
% retourne la liste de fichiers. s'emploie comme fullfile()
% accepte les wildcard (*)

fullPath = fullfile(varargin{:});

if iscell(fullPath)
    [filename,dirname] = cellfun(@filelist,fullPath,'uni',0);
    filename = vertcat(filename{:});
    dirname = vertcat(dirname{:});
    return
end

d = dir(fullPath);
idx = ~[d.isdir];
filename={d(idx).name}';
dirname={d(idx).folder}';

if nargout == 3
    fullname = fullfile(dirname,filename);
end
end


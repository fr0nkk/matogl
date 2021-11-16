function [filenames,dirnames,fullnames] = filelist(varargin)
% returns files matching the requested path/file.
% can be used like fullfile()
% f = filelist('C:\SomeDir\abc');
%   returns all filenames (including extensions) contained in 'C:\SomeDir\abc'.
%   Same as filelist('C:\SomeDir','abc')
% f = filelist('C:\SomeDir\abc\*.jpg');
%   returns only matching files, using the * wildcard
% [f,d] = filelist( ___ )
%   Also return the directory of each file
%   Useful when using it like fullfile('C:\*\*.jpg')
% [ __ , fullname ] = filelist( ___ )
%   Also return the full file path of each file.

fullPath = fullfile(varargin{:});

if iscell(fullPath)
    [filenames,dirnames] = cellfun(@filelist,fullPath,'uni',0);
    filenames = vertcat(filenames{:});
    dirnames = vertcat(dirnames{:});
    return
end

d = dir(fullPath);
idx = ~[d.isdir];
filenames={d(idx).name}';
dirnames={d(idx).folder}';

if nargout == 3
    fullnames = fullfile(dirnames,filenames);
end
end


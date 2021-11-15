function S = readply(fn)
% ASCII ply reader
% returns a struct containing elements and their properties
% todo - add binary support

fid = fopen(fn,'r');
temp = onCleanup(@() fclose(fid));
str = fread(fid,[1 2000],'uint8=>char');

endStr = 'end_header';
dataStart = regexp(str,['ply.+' endStr],'end');
assert(~isempty(dataStart),'invalid file');
header = str(1:dataStart-numel(endStr));
assert(contains(header,'format ascii 1.0'),'invalid format')
header = strtrim(strsplit(header,newline))';

S = struct;
S.comment = extractAfter(header(startsWith(header,'comment ')),' ');

header = header(startsWith(header,{'property ','element '}));
i0 = find(startsWith(header,'element '));
i1 = [i0(2:end) - 1 ; numel(header)];

frewind(fid);
fseek(fid,dataStart+1,0);

% todo - take into account the precision type to avoid filling everything with doubles.
% - will also be easier for binary support
for i=1:numel(i0)
    h = header(i0(i):i1(i));
    h1 = strsplit(h{1},' ');
    N = str2double(h1{3});
    if startsWith(h{2},'property list')
        data = textscan(fid,'%*f%s',N,'Delimiter',{'\n'});
        % todo - find better way to read list of variable length in 1 shot
        data = cellfun(@(c) sscanf(c,'%f'),data{1},'uni',0);
        S.(h1{2}) = data;
    else
        m = numel(h)-1;
        formatSpec = repmat('%f',1,m);
        data = textscan(fid,formatSpec,N,'Delimiter',{'\n'});
        h2 = cellfun(@(c) strsplit(c,' '),h(2:end),'uni',0);
        names = cellfun(@(c) c{3},h2,'uni',0);
        for j=1:m
            S.(h1{2}).(names{j}) = data{j};
        end
    end
end

end





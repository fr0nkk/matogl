function s = cppsubs(str)

str = strsplit(str,'.')';
type = repmat({'.'},size(str));

[subs,type] = cellfun(@getIndex,str,type,'uni',0);
subs = vertcat(subs{:});
type = vertcat(type{:});

s = cell2struct([type subs],{'type','subs'},2);

end

function [subs,type] = getIndex(str,type)

% extract name from "name[i][j]"
name = regexprep(str,'\[\d+?\]','');
subs = {name};
type = {type};

% extract [i j] from "name[i][j]"
ind = regexp(string(str),'(?<=\[)\d+?(?=\])','match');
if isempty(ind), return, end
ind = num2cell(double(ind)+1);
type = [type ; {'()'}];
subs = [subs ; {ind}];

end
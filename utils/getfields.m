function v = getfields(s,varargin)
% Get multiple elements from struct
% getfields(s,ele1,ele2,...,eleN) : s=struct, ele=struct element
% getfields(s,d,ele1,ele2,...,eleN) : d=dimension to concatenate elements (0=no concatenation)
%
% s = struct('a',1,'b',2);
% v = getfields(s,'a','b'); % = {1,2}
% v = getfields(s,2,'a','b'); % = [1,2]

dim = 0;
if isnumeric(varargin{1})
    dim = varargin{1};
    varargin = varargin(2:end);
end

v = cellfun(@(c) s.(c),varargin,'uni',0);

if dim
    v = cat(dim,v{:});
end

end


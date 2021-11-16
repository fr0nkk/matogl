function r = bafun(v,bitfcn,varargin)
% apply bit function elements of v
% for use with bitand/bitor/bitxor
% bafun([x1 x2 x3 x4],@bitor) = bitor(x1,bitor(x2,bitor(x3,x4)))

r = v(1);
for i=2:numel(v)
    r = bitfcn(r,v(i),varargin{:});
end

end
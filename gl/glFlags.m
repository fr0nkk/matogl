function bits = glFlags(gl,varargin)
% bitor multiple gl flags

bits = bafun(getfields(gl,2,varargin{:}),@bitor,'int32');
end
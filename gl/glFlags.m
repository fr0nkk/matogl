function bits = glFlags(gl,varargin)
    bits = bafun(getfields(gl,2,varargin{:}),@bitor,'int32');
end
function b = BitFlags(varargin)

gl = glmu.internal.getgl;

b = bafun(getfields(gl,2,varargin{:}),@bitor,'int32');

end


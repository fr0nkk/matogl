function [value,b] = Get(gl,getfcn,args,nb,type)
if nargin < 4, nb = 1; end
if nargin < 5, type = 'int32'; end

b = javabuffer(zeros(nb,1,type));
if ischar(args)
    args = gl.(args);
end
if ~iscell(args), args = {args}; end
getfcn(gl,args{:},b.p);
value = b.array;

end



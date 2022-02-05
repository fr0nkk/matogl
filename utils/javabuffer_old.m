function [b,nb,jt,mt] = javabuffer(data)
% returns a java.nio.[CLASS]Buffer
% works with float, integer and char arrays
mt = class(data);
[jt,nb] = javatype(mt);
sz = size(data);
i = sz > 0;
b = java.nio.([jt 'Buffer']).allocate(prod(sz(i)));
if all(i)
    b.put(data(:));
    b.rewind;
end

end

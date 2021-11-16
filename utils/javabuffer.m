function [b,nb] = javabuffer(data)
% returns a java.nio.[CLASS]Buffer
% works with float, integer and char arrays

[jt,nb] = javatype(class(data));
sz = size(data);
i = sz > 0;
b = java.nio.([jt 'Buffer']).allocate(prod(sz(i)));
if all(i)
    b.put(data(:));
    b.rewind;
end

end

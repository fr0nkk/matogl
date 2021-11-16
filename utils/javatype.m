function [jt,nb] = javatype(mattype)
% returns the equivalent java type of 'mattype' and the number of bytes per element

 jt = { % matlab, java
        'int8' 'Byte'
        'char' 'Char'
        'double' 'Double'
        'single' 'Float'
        'int32' 'Int'
        'int64' 'Long'
        'int16' 'Short'
        };

nb = [1 2 8 4 4 8 2]'; % bytes
if nargin > 0
    i = (mattype(1) == 'u') + 1;
    k = strcmp(mattype(i:end),jt(:,1));
    assert(any(k),['type not defined for java: ' mattype]);
    jt = jt{k,2};
    nb = nb(k);
end

end


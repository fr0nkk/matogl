function M = MScale3D(xyz)
% outputs scale matrix
% xyz can have 1 or 3 elements

M = eye(4,'like',xyz);
M(1:5:12) = xyz;
end


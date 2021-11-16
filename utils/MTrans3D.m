function M = MTrans3D(xyz)
% outputs translation matrix
% xyz can have 1 or 3 elements

M = eye(4,'like',xyz);
M(1:3,4) = xyz;
end


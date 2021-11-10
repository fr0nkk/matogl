function M = MTrans3D(xyz)
    M = eye(4,'like',xyz);
    M(1:3,4) = xyz;
end


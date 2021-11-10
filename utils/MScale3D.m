function M = MScale3D(xyz)
    M = eye(4,'like',xyz);
    M(1:5:12) = xyz;
end


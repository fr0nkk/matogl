function M = MRot3D(a,degFlag,order)
% outputs rotation matrix for rotating a = [rot x, rot y, rot z] in the
% order specified, default rotation order is [3 2 1] (ZYX)

    if nargin < 2, degFlag = 0; end
    if nargin < 3, order = [3 2 1]; end

    if degFlag
        % convert to radians
        a = a*(pi/180);
    end

    persistent RF
    if isempty(RF)
        RF{1} = @(t) [1 0 0 ; 0 cos(t) -sin(t) ; 0 sin(t) cos(t)]; % rot x
        RF{2} = @(t) [cos(t) 0 sin(t) ; 0 1 0 ; -sin(t) 0 cos(t)]; % rot y
        RF{3} = @(t) [cos(t) -sin(t) 0 ; sin(t) cos(t) 0 ; 0 0 1]; % rot z
    end
    
    j = order(1);
    R = RF{j}(a(j));
    for i=2:numel(order)
        j = order(i);
        R = R * RF{j}(a(j));
    end
    
    M = eye(4,'like',a);
    M(1:3,1:3) = R;
end


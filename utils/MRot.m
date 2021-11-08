function M = MRot(a,degFlag,revOrderFlag)

if nargin < 2, degFlag = 0; end
if nargin < 3, revOrderFlag = 0; end

if degFlag
    a = a/180*pi;
end

RX = @(t) [1 0 0 ; 0 cos(t) -sin(t) ; 0 sin(t) cos(t)];
RY = @(t) [cos(t) 0 sin(t) ; 0 1 0 ; -sin(t) 0 cos(t)];
RZ = @(t) [cos(t) -sin(t) 0 ; sin(t) cos(t) 0 ; 0 0 1];

if revOrderFlag
    M = RX(a(1))*RY(a(2))*RZ(a(3));
else
    M = RZ(a(3))*RY(a(2))*RX(a(1));
end

end


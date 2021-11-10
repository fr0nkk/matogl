function M = MTransform(type,in,degFlag)
if nargin < 3, degFlag = 0; end

M = eye(4,'like',in);
switch type
    case 'R'
        % rotation, in=xyz
        M(1:3,1:3) = MRot(in,degFlag,0);
    case 'RR'
        % rotation reverse order, in=xyz
        M(1:3,1:3) = MRot(in,degFlag,1);
    case 'T'
        % translation, in=xyz
        M(1:3,4) = in;
    case 'S'
        % scale, in=xyz
        M(1:5:12) = in;
    case 'P'
        % perspective, in=[width height near far]
        % http://www.songho.ca/opengl/gl_projectionmatrix.html
        r=in(1)/2; t=in(2)/2; n=in(3); f=in(4);
        M([1 6 11 12 15 16]) = [n/r n/t (f+n)/(n-f) -1 2*f*n/(n-f) 0];
    case 'PA'
        % perspective, in=[aspectRatio verticalFov near far]
        ar=in(1); fov=in(2); n=in(3); f=in(4);
        if degFlag, fov=fov/180*pi; end
        M([1 6 11 12 15 16]) = [1/(ar*tan(fov/2)) 1/tan(fov/2) (f+n)/(n-f) -1 2*f*n/(n-f) 0];
    case 'O' % ortho
        r=in(1)/2; t=in(2)/2; n=in(3); f=in(4);
        M([1 6 11 15]) = [1/r 1/t 2/(n-f) (f+n)/(n-f)];
    otherwise
        error(['invalid transform type: ' type]);
end

end


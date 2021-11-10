n = 100;
% a = linspace(0,1,2*n+1);
% [X,Y] = ndgrid(a,a);
% Z = membrane(1,n);
% pos = single([X(:) Y(:) Z(:)]);
% t = delaunay(X(:),Y(:));
% vwr = gl3d(pos,[],[]);


[X,Y,Z] = peaks(2*n);
t = delaunay(X(:),Y(:));
pos = single([X(:) Y(:) Z(:)]);
vwr = gl3d(pos,[],[],t);
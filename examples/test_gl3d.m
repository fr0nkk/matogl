n = 100;
a = linspace(0,1,2*n+1);
[X,Y] = ndgrid(a,a);
Z = membrane(1,n);
pos = single([X(:) Y(:) Z(:)]);
T = delaunay(X(:),Y(:));

gl3DViewer(pos,[1 1 1]);

gl3DViewer(pos,[],jet(256),T);

[loc,faces] = plyRead('bun_zipper.ply',1);
M = MRot3D([-90 0 0],1);
loc = loc * M(1:3,1:3);
gl3DViewer(loc,[],[],faces);
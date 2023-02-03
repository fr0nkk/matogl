% load bunny
data = readply('bun_zipper.ply');
loc = getfields(data.vertex,2,'x','y','z');
faces = vertcat(data.face{:});

% make bunny upright (Z up)
M = MRot3D([-90 0 0],1) * MScale3D(20);
loc = loc * M(1:3,1:3);

% mesh view, white
glViewer3D(loc,[1 1 1],faces);

% point cloud, auto color (scaled on Z)
% glViewer3D(loc);

% meshview, auto color
% glViewer3D(loc,[],faces);

% mesh view, confidence gray scale
% glViewer3D(loc,data.vertex.confidence,faces);




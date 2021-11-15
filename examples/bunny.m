% load bunny
data = readply('bun_zipper.ply');
loc = getfields(data.vertex,2,'x','y','z');
faces = vertcat(data.face{:});

% make bunny upright (Z up)
M = MRot3D([-90 0 0],1) * MScale3D(20);
loc = loc * M(1:3,1:3);

% mesh view, white
gl3DViewer(loc,[1 1 1],faces);

% point cloud, auto color (scaled on Z)
% gl3DViewer(loc);

% meshview, auto color
% gl3DViewer(loc,[],faces);

% mesh view, confidence gray scale
% gl3DViewer(loc,data.vertex.confidence,faces);




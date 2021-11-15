addpath('gl');
addpath('utils');
addpath('examples');

% Example of a basic OpenGL render
SimpleTriangle;

% Showcase of some basic home made gl utility
Simple3D;

% showcase of more advanced gl utility: a polyvalent OpenGL 3D Viewer.
% A call without arguments shows peaks() mesh with 250k points.
% doc gl3DViewer
gl3DViewer();

% load and display the Stanford bunny with the GL 3D Viewer
bunny;
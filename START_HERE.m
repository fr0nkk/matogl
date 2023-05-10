addpath('gl');
addpath('utils');
addpath('examples');

% Example of a basic OpenGL render: Hello Triangle
glExample1; % using old OpenGL render pipeline
% glExample2; % using newer OpenGL render pipeline with shaders
% glExample3; % using glmu to abstract some initializations
% glExample4; % using glmu to abstract almost all initializations

% Showcase of some basic glmu usage
glExample5;

% Showcase of more advanced glmu: a polyvalent OpenGL 3D Viewer.
% Left click: orbit - right click: pan - scroll wheel: zoom
% A call without arguments shows peaks() mesh with 160k points.
% doc glViewer3D
glViewer3D();

% load and display the Stanford bunny with the GL 3D Viewer
bunny;

% Showcase of more advanced glmu: fractal viewer (mandelbrot or julia)
% Contains a opengl subroutine uniform example
% scroll wheel: zoom - left click: pan
glFractal('mandelbrot');
% glFractal('julia');

% max 5000 iterations, double precision (for big boy GPU)
% F = glFractal('julia',true);
% F.maxIter = 5000;
% F.cmap = randn(256,3)./2+0.5; % trippy!!

% Example of compute shader usage : N body gravity simulation
% Close the window or ctrl+c to stop the simulation
% glNBodySim();



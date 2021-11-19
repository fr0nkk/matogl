addpath('gl');
addpath('utils');
addpath('examples');

% Example of a basic OpenGL render: Hello Triangle
glExample1; % using old OpenGL render pipeline
glExample2; % using newer OpenGL render pipeline with shaders
glExample3; % using home made utility to abstract some initializations

% Showcase of some basic home made utility
glExample4;

% Showcase of more advanced utility: a polyvalent OpenGL 3D Viewer.
% Left click to rotate, right click to translate, scroll wheel to zoom
% A call without arguments shows peaks() mesh with 160k points.
% doc glViewer3D
glViewer3D();

% load and display the Stanford bunny with the GL 3D Viewer
bunny;

% Showcase of a mandelbrot set explorer using opengl
% max 100 iterations, single precision
glMandelbrot(100,false); 

% max 5000 iterations, double precision (for big boy GPU)
% glMandelbrot(5000,true);
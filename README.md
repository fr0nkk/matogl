# MATLAB OpenGL
![examples](https://user-images.githubusercontent.com/93832337/141909918-ce710200-c534-4bd3-a3f0-428569bae56b.png)

Access the OpenGL rendering pipeline directly from matlab.

No mex file, toolbox, or any other external library needed.

[![View Matlab OpenGL on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/102109-matlab-opengl)

## Examples
A few examples are included, see `START_HERE.m` for a brief description of each of them.

## Making your own application
The main starting point is the class `glCanvas`. Set it as a superclass for your application.

You need to define the following abstract methods. In each of these methods, the `d` argument is the GLDrawable and the `gl` argument is the current GL context.
- ### `InitFcn(obj,d,gl,varargin)`
  - Called once when you run `Init(frame,glProfile,multisample,arg1,arg2,...)` in your class initialization method.
  - This should contain your opengl initialization stuff.

- ### `UpdateFcn(obj,d,gl)`
  - Called everytime `obj.Update()` is called. It has some built in stuff to resize when needed and to skip updates that saturate the render process.
  - This should contain your opengl render pipeline for each frame update requested.

- ### `ResizeFcn(obj,d,gl)`
  - Called once after initialization, just before the first frame update, and when the user changes the window size.
  - Always called just before the `UpdateFcn(obj,d,gl)`.
  - This should contain your opengl resize pipeline.

## Included gl utility
There are a few included utility in the `gl` directory. None of them are absolutely needed to make your own application. However, they help a lot to abstract some opengl stuff. Feel free to make your own or to contribute to this project!

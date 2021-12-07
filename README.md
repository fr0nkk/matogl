# MATLAB OpenGL
Access the OpenGL rendering pipeline directly from matlab.

No mex file, toolbox, or any other external library needed.

[![View Matlab OpenGL on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/102109-matlab-opengl)

## Examples
A few examples are included, see `START_HERE.m` for a brief description of each of them.

### 3D Viewer Example
![Screenshot 2021-12-07 153637](https://user-images.githubusercontent.com/93832337/145102562-3cc09f72-08ba-433b-9840-32b8796a1f32.png)
![Screenshot 2021-12-07 153653](https://user-images.githubusercontent.com/93832337/145102580-b2fb868e-75fd-4325-886f-e94005ad60fd.png)

### Mandelbrot Viewer Example
![Screenshot 2021-12-07 153529](https://user-images.githubusercontent.com/93832337/145102619-61f6f0d7-7512-41e2-8618-511df79a91d8.png)
![Screenshot 2021-12-07 153624](https://user-images.githubusercontent.com/93832337/145102630-99aef90c-e75d-4d47-8cfe-5a781fb1e994.png)

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
  - Always called just before the `UpdateFcn(obj,d,gl)`, when needed.
  - This should contain your opengl resize pipeline.

## GL Matlab Utility (glmu)
An utility package is included in `gl\+glmu`. The more advanced examples use it. It is not needed to make your own application. However, it helps a lot to abstract some opengl stuff. Feel free to make your own or to contribute to this project!

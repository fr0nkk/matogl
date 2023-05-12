# Access OpenGL from MATLAB
Access the OpenGL rendering pipeline directly from matlab.

No mex file, toolbox, or any other external library needed.

[![View Matlab OpenGL on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/102109-matlab-opengl)

## Examples
A few examples are included, see `START_HERE.m` for a brief description of each of them.

### 3D Viewer Example
![Screenshot 2021-12-07 153637](https://user-images.githubusercontent.com/93832337/145102562-3cc09f72-08ba-433b-9840-32b8796a1f32.png)
![Screenshot 2021-12-07 153653](https://user-images.githubusercontent.com/93832337/145102580-b2fb868e-75fd-4325-886f-e94005ad60fd.png)

### Fractal Viewer Example
![Screenshot 2021-12-07 153529](https://user-images.githubusercontent.com/93832337/145102619-61f6f0d7-7512-41e2-8618-511df79a91d8.png)
![image](https://github.com/fr0nkk/matogl/assets/93832337/4a62d6c8-8f4a-41c4-962b-7ceadd749cf0)


## Making your own application
The main starting point is the class `GLController` (or `glmu.GLController` to use the functions in the glmu package). Set it as a superclass for your class that manages the rendering.

You need to define the following abstract methods. In each of these methods, the `gl` argument is the current GL context.
- #### `InitFcn(obj,gl,varargin)`
  - Called once when you run `canvas.Init(arg1, arg2, ...)` in your class initialization method.
  - This should contain your opengl initialization stuff.

- #### `UpdateFcn(obj,gl)`
  - Called everytime `canvas.Update()` is called. It has some built in stuff to resize when needed and to skip updates that saturate the render process.
  - This should contain your opengl render pipeline for each frame update requested.

- #### `ResizeFcn(obj,gl,sz)`
  - Called once after initialization, just before the first frame update, and when the user changes the window size.
  - Always called just before the `UpdateFcn(...)`, when needed.
  - This should contain your opengl resize pipeline.
  - This one is optionnal. If not set, it defaults to `gl.glViewport(0,0,sz(1),sz(2));`

There are two ways to setup the render process.
### All in one way
Make a `GLController` subclass like so:
```
classdef myApp < GLController
  methods
    function obj = myApp()
      frame = JFrame('myApp'); % create java frame
      canvas = GLCanvas('GL3'); % create glcanvas
      frame.add(canvas); % add glcanvas
      obj.setGLCanvas(canvas); % set obj as the canvas controller
      canvas.Init;
    end
    
    function InitFcn(obj,gl)
      %...
    end
    
    function UpdateFcn(obj,gl)
      %...
    end
  end
end
```
### Separate controller way
If you don't want to end with a huge class, you can make a separate GLController just for the Init, Resize and Update functions.
Make the `GLController` subclass:
```
classdef myController < GLController
  methods
    function InitFcn(obj,gl)
      %...
    end
    
    function UpdateFcn(obj,gl)
      %...
    end
  end
end
```
Then, in the main application, you can create the window with:
```
frame = JFrame('WindowName'); % create java frame
canvas = GLCanvas('GL3'); % create glcanvas
frame.add(canvas); % add glcanvas
ctrl = myController; % construct the controller
ctrl.setGLCanvas(canvas); % assign the canvas
canvas.Init;
```

### Using gl when not in `InitFcn`, `UpdateFcn` or `ResizeFcn`
You can call gl commands when not inside one of these functions. To do so, use `[gl,temp] = canvas.getContext`. The temp output argument is the context lock and must be requested. When temp goes out of scope, gl commands will throw errors or run without doing anything.

## GL Matlab Utility (glmu)
An utility package is included in `gl\+glmu`. To use this package, the controller must be a `glmu.GLController`. The more advanced examples use it.

It is not needed to make your own application. However, it helps a lot to abstract some opengl stuff. Feel free to make your own or to contribute to this project!

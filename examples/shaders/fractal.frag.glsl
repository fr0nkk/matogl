#version 400

layout(location=0) out vec4 FragColor;

in vec2 coords;

#ifdef DEEP
    #define _vec2 dvec2
    #define _vec4 dvec4
    #define _float double
#else
    #define _vec2 vec2
    #define _vec4 vec4
    #define _float float
#endif

uniform _float scale = 1.0;
uniform _vec2 offset = _vec2(0.0);
uniform _vec2 ratio = _vec2(1.0);
uniform vec3 maxColor = vec3(0.0);
uniform _vec2 seed = _vec2(0.0);

uniform vec3[256] cmap;

uniform int maxIter = 100;

subroutine _vec4 fractal_set(_vec2);

subroutine(fractal_set) _vec4 mandelbrot(_vec2 loc)
{
    return _vec4(_vec2(coords.rg)*ratio*scale+offset,loc);
}

subroutine(fractal_set) _vec4 julia(_vec2 loc)
{
    return _vec4(loc,_vec2(coords.rg)*ratio*scale+offset);
}

subroutine uniform fractal_set fractal;

_vec2 ComplexSquare(_vec2 c)
{
    return _vec2(c.x*c.x - c.y*c.y, 2.0*c.x*c.y);
}

void main(){

    _vec4 cz = fractal(seed);
    _vec2 c = cz.xy;
    _vec2 z = cz.zw;
    
    int i = 0;
	for(i;i<maxIter;i++){
        z = ComplexSquare(z) + c;
		if(length(z) > 2.0) 
        {
            FragColor = vec4(cmap[i % 255].rgb,1.0);
            return;
        }
	}
    FragColor = vec4(maxColor.rgb,1.0);
}

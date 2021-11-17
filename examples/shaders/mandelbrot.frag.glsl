#version 400

layout(location=0) out vec4 FragColor;

in vec2 coords;

#ifdef DEEP
#define _vec2 dvec2
#define _float double
#else
#define _vec2 vec2
#define _float float
#endif
uniform _float scale = 1.0;
uniform _vec2 offset = vec2(0.0);
uniform _vec2 ratio = vec2(1.0);
uniform vec3 maxColor = vec3(0.0);

uniform vec3[256] cmap;

uniform int maxIter = 100;

void main(){
    _vec2 c = _vec2(coords.rg)*ratio*scale+offset;
    _vec2 z = _vec2(0,0);
    int i = 0;
	for(i;i<maxIter;i++){
        z = _vec2(z.x*z.x - z.y*z.y , 2.0*z.x*z.y) + c;
		if(length(z) > 2.0) 
        {
            FragColor = vec4(cmap[i % 256].rgb,1.0);
            return;
        }
	}
    FragColor = vec4(maxColor.rgb,1.0);
    
}

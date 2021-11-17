#version 330

layout(location=0) out vec4 FragColor;

in vec2 coords;

uniform float scale = 1.0;
uniform vec2 offset = vec2(0.0);
uniform vec2 ratio = vec2(1.0);
uniform vec3 maxColor = vec3(0.0);

uniform vec3[256] cmap;

uniform int maxIter = 100;

void main(){
    vec2 c = coords.rg*ratio*scale+offset;
    vec2 z = vec2(0,0);
    int i = 0;
	for(i;i<maxIter;i++){
        z = vec2(z.x*z.x - z.y*z.y , 2.0*z.x*z.y) + c;
		if(length(z) > 2.0) 
        {
            FragColor = vec4(cmap[i % 256].rgb,1.0);
            return;
        }
	}
    FragColor = vec4(maxColor.rgb,1.0);
    
}

#version 330

layout(location=0) out vec4 FragColor;

in vec2 TexCoords;

uniform sampler2D colorTex;
uniform float edlStrength = 0.1f;
uniform vec2 scrSz = vec2(500.0f);

vec2 foffset[4] = vec2[](
vec2(-1,0),
vec2(1,0),
vec2(0,-1),
vec2(0,1)
);

void main(){
    vec4 neighboor;
    vec4 color = texture(colorTex,TexCoords);
    
    float nd = 0.0f;
    float shade = 0.0f;
    float d = log2(color.a);
    
    for (int i=0;i<4;i++)
    {
        neighboor = texture(colorTex,TexCoords + foffset[i]/scrSz);
        nd = (neighboor.a > 0.0) ? log2(neighboor.a) : 1000;
        shade -= max(0.0,d-nd);
    }
    
    float mean_scrSize = (scrSz.x + scrSz.y) / 2.0f;
    shade = exp2(edlStrength*mean_scrSize*shade);
    FragColor = vec4(color.rgb * shade,1.0f);
}

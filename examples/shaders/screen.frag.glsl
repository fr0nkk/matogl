#version 460

in vec2 TexCoords;

layout(location=0) out vec4 FragColor;

uniform sampler2D colorTex;
uniform sampler2D infoTex;
uniform float edlStrength = 0.2f;
uniform vec2 scrSz = vec2(500.0f);

vec2 foffset[4] = vec2[](
vec2(-1,0),
vec2(1,0),
vec2(0,-1),
vec2(0,1)
);

void main(){
vec4 neighboor;
vec4 info = texture(infoTex,TexCoords);

float nd = 0.0f;
float shade = 0.0f;
float d = log2(info.w);

for (int i=0;i<4;i++)
{
    neighboor = texture(infoTex,TexCoords + foffset[i]/scrSz);
    nd = (neighboor.z > 0.5) ? log2(neighboor.w) : 1000;
    shade -= max(0.0,d-nd);
}
float mean_scrSize = (scrSz.x + scrSz.y) / 2.0f;
shade = exp2(edlStrength*mean_scrSize*shade);
FragColor = texture(colorTex,TexCoords)*shade;


}

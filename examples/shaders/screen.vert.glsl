#version 330

layout(location = 0) in vec4 quadVerts;

out vec2 TexCoords;

void main(){
gl_Position = vec4(quadVerts.xy,0.0,1.0);
TexCoords = vec2(quadVerts.zw);
}
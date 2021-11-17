#version 400

layout(location = 0) in vec2 vert;

out vec2 coords;

void main(){
coords = vert;
gl_Position = vec4(vert.xy,0.0,1.0);
}
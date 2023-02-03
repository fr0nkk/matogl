#version 330

layout(location = 0) in vec4 vertex_position;

uniform mat4 view = mat4(1.0);
uniform mat4 projection = mat4(1.0);
uniform float maxWeight = 1000.0;

out float c;

void main(){
gl_Position = projection * (view * vec4(vertex_position.xyz,1.0));
c = vertex_position.w/maxWeight;
}
#version 330

layout(location = 0) in vec3 vertex_position;
layout(location = 1) in vec3 vertex_color;
out vec3 color;

uniform mat4 model = mat4(1.0);
uniform mat4 view = mat4(1.0);
uniform mat4 projection = mat4(1.0);

void main(){
color = vertex_color;
gl_Position = projection * view * model * vec4(vertex_position,1.0);
}
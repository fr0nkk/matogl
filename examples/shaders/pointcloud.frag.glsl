#version 460 core

in vec3 color;
in vec4 info;

layout(location = 0) out vec4 frag_color;
layout(location = 1) out vec4 frag_info;

void main(){
frag_color = vec4(color, 1.0f);
frag_info = info;
}

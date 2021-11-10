#version 460 core

layout(location = 0) in vec3 vertex_position;
layout(location = 1) in vec3 vertex_color;

out vec3 color;
out vec4 info;

uniform float ptSize = 1.0f;
uniform mat4 model = mat4(1.0f);
uniform mat4 view = mat4(1.0f);
uniform mat4 projection = mat4(1.0f);

uniform float pointSizeDist = 1.0f;
uniform float maxPointSize = 1.0f;

void main()
{
color = vertex_color;

vec4 camView = view * (model * vec4(vertex_position,1.0f));
gl_Position = projection * camView;

info = vec4(0,0,gl_DrawID+1,-camView.z);

}

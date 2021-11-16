#version 330 core

layout(location = 0) in vec3 vertex_position;
layout(location = 1) in vec3 vertex_color;

out vec4 color;

uniform float ptSize = 1.0f;
uniform mat4 model = mat4(1.0f);
uniform mat4 view = mat4(1.0f);
uniform mat4 projection = mat4(1.0f);

uniform float pointSizeDist = 1.0f;
uniform float maxPointSize = 1.0f;

void main()
{

vec4 camView = view * (model * vec4(vertex_position,1.0f));
gl_Position = projection * camView;

color = vec4(vertex_color,-camView.z);

}

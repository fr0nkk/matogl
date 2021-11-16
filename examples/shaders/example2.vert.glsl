#version 330
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

uniform vec2 scale = vec2(1.0,1.0);

uniform mat4 model = mat4(1.0);
uniform mat4 view = mat4(1.0);
uniform mat4 projection = mat4(1.0);

void main()
{
	gl_Position = projection * view * model * vec4(aPos, 1.0);
	TexCoord = (aTexCoord.xy - 0.5) * scale + 0.5;
}
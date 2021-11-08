#version 400
layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

uniform vec2 scale = vec2(1.0,1.0);

void main()
{
	gl_Position = vec4(aPos,0.0, 1.0);
	TexCoord = (aTexCoord.xy - 0.5) * scale + 0.5;
}
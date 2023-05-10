#version 330
out vec4 FragColor;

in vec2 TexCoord;

uniform sampler2D mytexture;

void main()
{
	FragColor = texture(mytexture, TexCoord);
}
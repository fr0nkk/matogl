#version 400 core

layout(location = 0) out vec4 frag_color;

in vec4 color;

subroutine float colorScale();
subroutine uniform colorScale colorScaleSelection;

subroutine (colorScale) float DoNothing()
{
    return 1.0;
}

subroutine (colorScale) float DoHalf()
{
    return 0.5;
}

void main(){
frag_color = color * colorScaleSelection();
}

#version 330

out vec4 frag_color;
in float c;
void main(){
frag_color = vec4(vec3(c),1.0);
}
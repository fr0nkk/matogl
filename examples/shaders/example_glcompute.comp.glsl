#version 430 core

layout(std140, binding = 0) buffer Buffer_A
{
vec4 A[];
};

layout(std140, binding = 1) buffer Buffer_B
{
vec4 B[];
};

uniform float const1 = 0;

layout( local_size_x = WORKGROUPSIZE, local_size_y = 1, local_size_z = 1 ) in;

void main(){
uint gid = gl_GlobalInvocationID.x;

vec4 val = A[gid];
for (int i = 0;i < 100; i++)
{
    val = val + sqrt(val) + sin(val) + cos(val) + const1;
}
B[gid] = val;
}


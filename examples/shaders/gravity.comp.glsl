#version 430 core

layout(std140, binding = 0) buffer A_Pos
{
vec4 APos[];
};

layout(std140, binding = 1) buffer A_Vel
{
vec4 AVel[];
};

uniform float G = 10;
uniform float dt = 1;

layout( local_size_x = WORKGROUPSIZE, local_size_y = 1, local_size_z = 1 ) in;

void main(){
uint gid = gl_GlobalInvocationID.x;

vec3 p = APos[gid].xyz;
vec3 v = AVel[gid].xyz;

vec3 acc = vec3(0.0);
vec4 L = vec4(0,0,0,10);
vec4 p2;
float R;

for (int i=0;i<APos.length();i++)
{
if(i==gid) continue;
p2 = APos[i];
L.xyz = p2.xyz-p.xyz;
R = length(L);
acc += p2.w/pow(R,3)*L.xyz;
}
acc = acc * G;

barrier();
memoryBarrier();

v += acc*dt/2;
p += v*dt;
v += acc*dt/2;

APos[gid].xyz = p;
AVel[gid].xyz = v;
}

//F = G*m1*m2/(r*r)
// a = F/m;
// v = v + a*t
// v = v + F/m*t
// x = x + v*t

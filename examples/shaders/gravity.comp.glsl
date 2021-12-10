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

vec4 p = APos[gid];
vec3 v = AVel[gid].xyz;


vec3 F = vec3(0.0);
vec3 L;
vec4 p2;
float R;

//F = G*m1*m2/(r*r)
for (int i=0;i<APos.length();i++)
{
if(i==gid) continue;
p2 = APos[i];
L = p2.xyz-p.xyz;
R = max(10.0,length(L)); // avoid particles flying out
R = min(R,1000.0); // try to attract back far particles
F = F + G*p.w*p2.w/pow(R,2)*normalize(L);
}

// a = F/m;
// v = v + a*t
// v = v + F/m*t
v += F / p.w * dt;

// x = x + v*t
p.xyz += v * dt;
APos[gid].xyz = p.xyz;
AVel[gid].xyz = v;
}

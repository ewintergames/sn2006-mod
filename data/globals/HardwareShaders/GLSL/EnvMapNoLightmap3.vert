// #class Object

#include "std.gh"
#include "fog.gh"

varying vec4 position;
varying vec4 diffuse;
varying float fog;
varying vec2 uv0;
varying vec3 reflUV;

uniform vec4 EyeInObjectSpace;
uniform vec4 FogParams;
uniform vec4 VectorParam0_ReflectionDrift;

#define MAX_LIGHTS  4

#include "lighting.gh"

// #invertalpha
// #default ReflectionDrift = 0 0 0 0

void main()
{
    gl_Position = ftransform();

    // lighting
    vec3 color=vertexDiffuse(gl_Vertex.xyz,gl_Normal.xyz);
    diffuse = vec4(color,1);

    vec3 refl = reflect(EyeInObjectSpace.xyz-gl_Vertex.xyz,gl_Normal.xyz);
    reflUV=vec3(dot(refl.xz,VectorParam0_ReflectionDrift.yz),refl.y,dot(refl.xz,VectorParam0_ReflectionDrift.xy));

    uv0 = gl_MultiTexCoord0.st;
    fog = fogFactor(gl_Vertex.xyz,EyeInObjectSpace.xyz,FogParams);
}


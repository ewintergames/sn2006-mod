
#include "std.gh"
#include "fog.gh"

varying vec4 position;
varying vec4 diffuse;
varying float fog;
varying vec2 uv0;
varying vec3 reflUV;

uniform sampler2D Texture0;
uniform samplerCube Texture2_EnvMap;
uniform vec4 FogColor;
uniform float FloatParam0_ReflectionIntenstiy;
uniform float FloatParam1_BlendingFactor;
uniform float Blend;


// #default ReflectionIntenstiy = 1
// #default BlendingFactor = 1
// #default Texture2_EnvMap = CubeMaps\Sample_CubeMap.tga

void main()
{
    vec4 src=texture2D(Texture0,uv0);
    vec4 reflection=vec4((textureCube(Texture2_EnvMap,reflUV)*FloatParam0_ReflectionIntenstiy*src.w).xyz,0.0);
    src=saturate(src+reflection);
    src=src*diffuse;
    src=saturate(vec4(src.xyz,(src.w-dot(src,BW)*FloatParam1_BlendingFactor-1.0)*Blend+1.0));
    
    gl_FragColor=fogSolid(src,FogColor,fog);
}

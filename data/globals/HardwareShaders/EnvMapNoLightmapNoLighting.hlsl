// #class Object

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float2 uv0          : TEXCOORD0;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float  fog          : FOG;
    float2 uv0          : TEXCOORD0;
    float3 reflUV       : TEXCOORD2;
};

#define MAX_LIGHTS    4

#include "lighting.cginc"

// #invertalpha
// #default ReflectionDrift = 0 0 0 0

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 Ambient,
        uniform float4 FogParams,
        uniform float4 VectorParam0_ReflectionDrift
        )
{
    float4 pos=vin.position;

    vout.position = mul(ModelViewProjMatrix, pos);
    vout.uv0 = vin.uv0;
    float3 refl = reflect(EyeInObjectSpace.xyz-vin.position.xyz,vin.normal);
    refl=float3(dot(refl.xz,VectorParam0_ReflectionDrift.yz),refl.y,dot(refl.xz,VectorParam0_ReflectionDrift.xy));
    vout.reflUV=refl;
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}

// #default ReflectionIntenstiy = 1
// #default BlendingFactor = 1
// #default Texture2_EnvMap = CubeMaps\Sample_CubeMap.tga

#define BW float4(0.239,0.686,0.075,0)

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform samplerCUBE Texture2_EnvMap,
            uniform float FloatParam0_ReflectionIntenstiy,
            uniform float FloatParam1_BlendingFactor,
            uniform float Blend
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv0);
    float4 reflection=float4((texCUBE(Texture2_EnvMap,In.reflUV)*FloatParam0_ReflectionIntenstiy*src.w).xyz,0);
    src=saturate(src+reflection);
    src=saturate(float4(src.xyz,(src.w-dot(src,BW)*FloatParam1_BlendingFactor-1)*Blend+1));
    return src;
}

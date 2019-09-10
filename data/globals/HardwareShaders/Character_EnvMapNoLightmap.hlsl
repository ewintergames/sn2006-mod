// #class Object

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float2 uv0          : TEXCOORD0;
    float4 weight       : BLENDWEIGHT;
    float4 indices      : BLENDINDICES;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
    float fog          : FOG;
    float2 uv0          : TEXCOORD0;
    float3 reflUV       : TEXCOORD2;
};

#if VS_VER_MAJOR >= 2
#define MAX_LIGHTS  4
#else
#define MAX_LIGHTS  2
#endif

#include "lighting.cginc"
#include "lighting2.cginc"

#include "Skinning.HLSLinc"

// #invertalpha
// #default ReflectionDrift = 0 0 0 0

#if VS_VER_MAJOR >= 2
void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 Ambient,
        uniform float4 FogParams,
        uniform float4 VectorParam0_ReflectionDrift,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS],
        uniform float4x3 BoneMatrices[MAX_SKINNING_BONES]
        )
{
    float3 pos, normal;
    Skin(pos,normal,vin.position,vin.normal.xyz,vin.indices,vin.weight,BoneMatrices);
    
    // lighting
    float4 color=vertexDiffuse(pos,normal,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    vout.diffuse = float4(color.xyz,1);
   
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
    vout.uv0 = vin.uv0;
    float3 refl = reflect(EyeInObjectSpace.xyz-pos,normal);
    refl=float3(dot(refl.xz,VectorParam0_ReflectionDrift.yz),refl.y,dot(refl.xz,VectorParam0_ReflectionDrift.xy));
    vout.reflUV=refl;
    vout.fog = 1 - fogFactor(pos,EyeInObjectSpace.xyz,FogParams);
}
#endif

// #default ReflectionIntenstiy = 1
// #default BlendingFactor = 1
// #default Texture2_EnvMap = CubeMaps\Sample_CubeMap.tga

#define BW float4(0.239,0.686,0.075,0)

#if PS_VER_MAJOR >= 2
float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform samplerCUBE Texture2_EnvMap,
            uniform float FloatParam0_ReflectionIntenstiy,
            uniform float FloatParam1_BlendingFactor,
            uniform float Blend
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv0);
    float4 reflection=float4((texCUBE(Texture2_EnvMap,In.reflUV)*FloatParam0_ReflectionIntenstiy*src.w).xyz,0);
    src=src*In.diffuse;
    src=saturate(src+reflection);
    src=saturate(float4(src.xyz,(src.w-dot(src,BW)*FloatParam1_BlendingFactor-1)*Blend+1));
    return src;
}
#endif

void vertex1_1(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 Ambient,
        uniform float4 FogParams,
        uniform float4 VectorParam0_ReflectionDrift,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS],
        uniform float4x3 BoneMatrices[MAX_SKINNING_BONES]
        )
{
    float3 pos, normal;
    Skin(pos,normal,vin.position,vin.normal.xyz,vin.indices,vin.weight,BoneMatrices);
    
    // lighting
    float4 color=vertexDiffuse(pos,normal,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    vout.diffuse = float4(color.xyz,1);
   
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
    vout.uv0 = vin.uv0;
    float3 refl = reflect(EyeInObjectSpace.xyz-pos,normal);
    refl=float3(dot(refl.xz,VectorParam0_ReflectionDrift.yz),refl.y,dot(refl.xz,VectorParam0_ReflectionDrift.xy));
    vout.reflUV=refl;
    vout.fog = 1 - fogFactor(pos,EyeInObjectSpace.xyz,FogParams);
}

float4 main1_1(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform samplerCUBE Texture2_EnvMap,
            uniform float FloatParam0_ReflectionIntenstiy,
            uniform float FloatParam1_BlendingFactor,
            uniform float Blend
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv0);
    float4 reflection=float4((texCUBE(Texture2_EnvMap,In.reflUV)*FloatParam0_ReflectionIntenstiy*src.w).xyz,0);
    src=src*In.diffuse;
    src=saturate(src+reflection);
    src.w*=Blend;
    return src;
}

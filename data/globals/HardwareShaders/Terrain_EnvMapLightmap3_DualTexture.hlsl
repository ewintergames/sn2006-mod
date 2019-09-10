// #class Terrain
// #Lightmap

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float2 uv0          : TEXCOORD0;
    float2 lmUV         : TEXCOORD1;
    float2 uv2          : TEXCOORD2;
    float4 mask         : COLOR0;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
    float  fog          : FOG;
    float2 uv0          : TEXCOORD0;
    float2 lmUV         : TEXCOORD1;
    float2 uv2          : TEXCOORD2;
    float3 reflUV       : TEXCOORD3;
};

#define MAX_LIGHTS    4
#include "lighting.cginc"
#include "lighting2.cginc"
#include "spec.cginc"

// #invertalpha
// #default ReflectionDrift = 0 0 0 0

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 Ambient,
        uniform float4 FogParams,
        uniform float4 VectorParam0_ReflectionDrift,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS]
        )
{
    float4 pos=vin.position;

    // lighting
    float4 color=vertexDiffuse(vin.position.xyz,vin.normal.xyz,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    vout.diffuse = float4(color.xyz,vin.mask.w);
   
    vout.position = mul(ModelViewProjMatrix, pos);
    vout.uv0 = vin.uv0;
    vout.lmUV = vin.lmUV;
    vout.uv2 = vin.uv2;
    float3 refl = reflect(EyeInObjectSpace.xyz-vin.position.xyz,vin.normal);
    refl=float3(dot(refl.xz,VectorParam0_ReflectionDrift.yz),refl.y,dot(refl.xz,VectorParam0_ReflectionDrift.xy));
    vout.reflUV=refl;
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}

// #default ReflectionIntenstiy = 1
// #default BlendingFactor = 1
// #default Texture3_EnvMap = CubeMaps\Sample_CubeMap.tga

#define BW float4(0.239,0.686,0.075,0)

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture1, uniform sampler2D Texture2,
            uniform samplerCUBE Texture3_EnvMap,
            uniform float FloatParam0_ReflectionIntenstiy,
            uniform float FloatParam1_BlendingFactor,
            uniform float Blend
            ) : COLOR
{
    half4 src1=half4(tex2D(Texture0,In.uv0));
    half4 src2=half4(tex2D(Texture2,In.uv2));
    half4 src=half4(lerp(src1.xyz, src2.xyz, In.diffuse.w), src1.w*(1-In.diffuse.w));

    float4 reflection=float4((texCUBE(Texture3_EnvMap,In.reflUV)*FloatParam0_ReflectionIntenstiy*src.w).xyz,0);
    src=src+reflection;
    src.xyz=src.xyz*saturate(In.diffuse.xyz+tex2D(Texture1,In.lmUV).xyz);
    src=saturate(float4(src.xyz,(src.w-dot(src,BW)*FloatParam1_BlendingFactor-1)*Blend+1));
    return src;
}

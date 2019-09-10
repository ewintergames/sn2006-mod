// #class Object
// #Lightmap

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float2 uv0          : TEXCOORD0;
    float2 lmUV         : TEXCOORD1;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
    float4 fog          : COLOR1;
    float2 uv0          : TEXCOORD0;
    float2 lmUV         : TEXCOORD1;
    float3 reflUV       : TEXCOORD2;
};

#define MAX_LIGHTS    4

#include "lighting.cginc"
#include "lighting2.cginc"

// #invertalpha
// #NoFog
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
    vout.diffuse = float4(color.xyz,1);
   
    vout.position = mul(ModelViewProjMatrix, pos);
    vout.uv0 = vin.uv0;
    vout.lmUV = vin.lmUV;
    float3 refl = reflect(EyeInObjectSpace.xyz-vin.position.xyz,vin.normal);
    refl=float3(dot(refl.xz,VectorParam0_ReflectionDrift.yz),refl.y,dot(refl.xz,VectorParam0_ReflectionDrift.xy));
    vout.reflUV=refl;
    vout.fog = fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams).xxxx;
}

// #default ReflectionIntenstiy = 1
// #default BlendingFactor = 1
// #default Texture2_EnvMap = CubeMaps\Sample_CubeMap.tga

#define BW float4(0.239,0.686,0.075,0)

half4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform samplerCUBE Texture2_EnvMap,
            uniform half FloatParam0_ReflectionIntenstiy,
            uniform half FloatParam1_BlendingFactor,
            uniform half Blend
            ) : COLOR
{
    half4 src=tex2D(Texture0,In.uv0);
    half4 reflection=half4((texCUBE(Texture2_EnvMap,In.reflUV)*FloatParam0_ReflectionIntenstiy*src.w).xyz,0);
    src=src*saturate(In.diffuse+tex2D(Texture1,In.lmUV));
    src=saturate(src+reflection);
    src=saturate(half4(src.xyz,(src.w-dot(saturate(src),BW)*FloatParam1_BlendingFactor-1)*Blend+1));
    src=fogHalfAdditive(src,In.fog);
    return src;
}

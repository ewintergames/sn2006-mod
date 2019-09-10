// #class Object
// #SkinningReplacement SFX_GizmoSource_HWSkin
// #NoFog

#define BW float4(0.239,0.686,0.075,0)
#define MAX_LIGHTS  4

#include "lighting2.cginc"

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float4 uv0          : TEXCOORD0;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float2 uv0          : TEXCOORD0;
    float4 color        : COLOR0;
};

// #default TimeSine = 2

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix, uniform float FloatParam1_TimeSine,
        uniform float4 Ambient,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS],
        uniform half2 Blend
        )
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.uv0=vin.uv0;
    float4 dif=vertexDiffuse(vin.position,vin.normal,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    vout.color=float4(dif.xyz,(0.7+0.3*FloatParam1_TimeSine)*Blend.x);
}

float4 main(in Vert2Frag In, uniform sampler2D Texture0,
        uniform float FrameTime) : COLOR
{
    float4 src=tex2D(Texture0,In.uv0);
    float intensity=dot(src.xyz*In.color.xyz,BW.xyz);
    return float4(saturate(3*intensity.xxx)*float3(0,0.3,1),In.color.w);
}


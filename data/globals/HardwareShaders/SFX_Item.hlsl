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
    float4 diffuse      : COLOR0;
    float2 uv0          : TEXCOORD0;
	float fog				: FOG;
};

// #default TimeSine = 1
// #default ExtraColor = 1 0 0 1

#define MAX_LIGHTS    4

#include "lighting.cginc"
#include "lighting2.cginc"

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 FogParams,
        uniform float4 EyeInObjectSpace,
        uniform float4 Ambient,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS],
        uniform float4 VectorParam1_ExtraColor,
        uniform float FloatParam2_TimeSine
        )
{

    vout.position = mul(ModelViewProjMatrix, vin.position);
    float4 color=vertexDiffuse(vin.position.xyz,vin.normal.xyz,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    color.xyz=saturate(color.xyz+VectorParam1_ExtraColor.xyz*(1+FloatParam2_TimeSine)*0.5);
    vout.diffuse=color;
	vout.uv0=vin.uv0;
	vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, 
            uniform float2 Blend
            ) : COLOR
{
    half4 src=tex2D(Texture0,In.uv0);
    src.xyz*=In.diffuse.xyz;
    src.w*=Blend.x;
    return src;
}

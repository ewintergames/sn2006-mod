// #class Object

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float2 uv           : TEXCOORD0;
    float4 weight       : BLENDWEIGHT;
    float4 indices      : BLENDINDICES;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float2 uv           : TEXCOORD0;
    float4 diffuse      : COLOR0;
    float fog          : FOG;
};

#define MAX_LIGHTS	4

#include "Skinning.HLSLinc"
#include "lighting.cginc"
#include "lighting2.cginc"

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix, uniform float4x3 BoneMatrices[MAX_SKINNING_BONES],
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4 Ambient,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS]
        )
{
    float3 pos, nor;
    Skin(pos,nor,vin.position,vin.normal,vin.indices,vin.weight,BoneMatrices);
    
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
    
    float4 color=vertexDiffuse(pos,nor,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    vout.diffuse = float4(color.xyz,1);
    vout.uv=vin.uv;
	float f = 1 - fogFactor(pos,EyeInObjectSpace.xyz,FogParams);
    vout.fog = f;
}

float4 main(in Vert2Frag In, uniform sampler2D Texture0,
            uniform float4 BlendFactors
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv);
    float4 color=float4(src.xyz*In.diffuse.xyz,src.w*BlendFactors.x+BlendFactors.y);
    return color;
}

void vertex1_1(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix, 
		uniform float4x3 BoneMatrices[MAX_SKINNING_BONES],
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4 Ambient,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS]
        )
{
    float3 pos, nor;
    Skin(pos,nor,vin.position,vin.normal,vin.indices,vin.weight,BoneMatrices);
    
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
    
    float4 color=vertexDiffuse(pos,nor,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    vout.diffuse = float4(color.xyz,1);
    vout.uv=vin.uv;
	float f = 1 - fogFactor(pos,EyeInObjectSpace.xyz,FogParams);
    vout.fog = f;
}


float4 main1_1(in Vert2Frag In, uniform sampler2D Texture0, uniform float4 BlendFactors) : COLOR
{
	float2 bf = saturate(BlendFactors.xy); // without saturate, there was a black screen (on GF5950Ultra)
    float4 src=tex2D(Texture0,In.uv);
	float4 color=float4(src.xyz*In.diffuse.xyz,src.w*bf.x+bf.y);
	return color;
}





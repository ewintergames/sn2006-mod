// #class Object

struct App2Vert
{
    float4 position     : POSITION;
    float4 weight       : BLENDWEIGHT;
    float4 indices      : BLENDINDICES;
};

struct Vert2Frag
{
    float4 position     : POSITION;
	float fog				: FOG;
};

#include "lighting.cginc"
#include "Skinning.HLSLinc"

void vertex(in App2Vert vin, out Vert2Frag vout,
		uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4x4 ModelViewProjMatrix, uniform float4x3 BoneMatrices[MAX_SKINNING_BONES])
{
    float3 pos;
    SkinPositionOnly(pos,vin.position,vin.indices,vin.weight,BoneMatrices);
    
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
	vout.fog=1 -  fogFactor(pos,EyeInObjectSpace.xyz,FogParams);
}

half4 main(in Vert2Frag In, uniform half4 VectorParam0) : COLOR
{
    return VectorParam0;
}


void vertex1_1(in App2Vert vin, out Vert2Frag vout,
		uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4x4 ModelViewProjMatrix, uniform float4x3 BoneMatrices[MAX_SKINNING_BONES])
{
    float3 pos;
    SkinPositionOnly(pos,vin.position,vin.indices,vin.weight,BoneMatrices);
    
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
	vout.fog=1 -  fogFactor(pos,EyeInObjectSpace.xyz,FogParams);
}

half4 main1_1(in Vert2Frag In, uniform half4 VectorParam0) : COLOR
{
    return VectorParam0;
}
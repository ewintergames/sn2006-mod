// #class SYS
// #hidden
// #NoFog

struct App2Vert
{
    float4 position     : POSITION;
    float4 weight       : BLENDWEIGHT;
    float4 indices      : BLENDINDICES;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
};

#include "Skinning.HLSLinc"

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix, uniform half4 ConstantColor, 
        uniform float4x3 BoneMatrices[MAX_SKINNING_BONES])
{
    float3 pos;
    SkinPositionOnly(pos, vin.position, vin.indices, vin.weight, BoneMatrices);
    
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
    
    float d=vout.position.z/vout.position.w;
    d=1-d;
    vout.diffuse=float4(ConstantColor.xyz,d);
}

half4 main(in Vert2Frag In) : COLOR
{
    return In.diffuse;
}


void vertex1_1(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix, uniform half4 ConstantColor, 
        uniform float4x3 BoneMatrices[MAX_SKINNING_BONES])
{
    float3 pos;
    SkinPositionOnly(pos, vin.position, vin.indices, vin.weight, BoneMatrices);
    
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
    
    float d=vout.position.z/vout.position.w;
    d=1-d;
    vout.diffuse=float4(ConstantColor.xyz,d);
}

half4 main1_1(in Vert2Frag In) : COLOR
{
    return In.diffuse;
}
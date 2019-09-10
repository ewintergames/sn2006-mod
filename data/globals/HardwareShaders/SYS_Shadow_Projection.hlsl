// #class SYS
// #hidden
// #NoFog

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float4 weight       : BLENDWEIGHT;
    float4 indices      : BLENDINDICES;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float2 uv           : TEXCOORD1;
    float3 gradient     : TEXCOORD2;
};

#include "Skinning.HLSLinc"

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix, 
        uniform float4 VectorParams[10], uniform float FloatParam1,       
        uniform float4x3 BoneMatrices[MAX_SKINNING_BONES])
{
    float3 pos;
    SkinPositionOnly(pos, vin.position, vin.indices, vin.weight, BoneMatrices);
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));

    float4x4 gradientProj;
    gradientProj[0]=VectorParams[0];
    gradientProj[1]=VectorParams[1];
    gradientProj[2]=VectorParams[2];
    gradientProj[3]=VectorParams[3];

    float4x4 textureProj;
    textureProj[0]=VectorParams[4];
    textureProj[1]=VectorParams[5];
    textureProj[2]=VectorParams[6];
    textureProj[3]=VectorParams[7];
    
    float4 txtUV=mul(float4(pos,1),textureProj);
    vout.uv=txtUV.xy/txtUV.w;
    
    float4 gradUV=mul(float4(pos,1),gradientProj);
    float dirFactor=step(-dot(vin.normal,VectorParams[9].xyz),0);
    vout.gradient=float3(1-gradUV.x,gradUV.y+FloatParam1,dirFactor);
}

half4 main(in Vert2Frag In, uniform sampler2D Texture0) : COLOR
{
    float4 shadow=tex2D(Texture0,In.uv);
    float gradient=saturate(In.gradient.x);
    float depthDifference=(1-shadow.w)-In.gradient.y;
    float depthStep=step(depthDifference,0);
    
    return half4(shadow.xyz*gradient,depthStep*In.gradient.z);
}

void vertex1_1(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix, 
        uniform float4 VectorParams[10], uniform float FloatParam1,       
        uniform float4x3 BoneMatrices[MAX_SKINNING_BONES])
{
    float3 pos;
    SkinPositionOnly(pos, vin.position, vin.indices, vin.weight, BoneMatrices);
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));

    float4x4 gradientProj;
    gradientProj[0]=VectorParams[0];
    gradientProj[1]=VectorParams[1];
    gradientProj[2]=VectorParams[2];
    gradientProj[3]=VectorParams[3];

    float4x4 textureProj;
    textureProj[0]=VectorParams[4];
    textureProj[1]=VectorParams[5];
    textureProj[2]=VectorParams[6];
    textureProj[3]=VectorParams[7];
    
    float4 txtUV=mul(float4(pos,1),textureProj);
    vout.uv=txtUV.xy/txtUV.w;
    
    float4 gradUV=mul(float4(pos,1),gradientProj);
    float dirFactor=step(-dot(vin.normal,VectorParams[9].xyz),0);
    vout.gradient=float3(1-gradUV.x,gradUV.y+FloatParam1,dirFactor);
}

half4 main1_1(in Vert2Frag In, uniform sampler2D Texture0) : COLOR
{
    float4 shadow=tex2D(Texture0,In.uv);
    float gradient=saturate(In.gradient.x);
	
    float depthDifference=(1-shadow.w)-In.gradient.y;
	float depthStep = saturate(depthDifference*2);
	
    return half4(shadow.xyz*gradient,depthStep*In.gradient.z);
}
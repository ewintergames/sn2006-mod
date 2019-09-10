// #class SYS
// #hidden
// #NoFog

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
    float2 uv0          : TEXCOORD0;
};

#include "skinning.HLSLinc"

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float2 Blend,
        uniform float4 VectorParam2,
        uniform float4 VectorParam3,
        uniform float4 VectorParam4,
        uniform float4 VectorParam5,
        uniform float4 VectorParam6,
        uniform float4 VectorParam7,
        uniform float4x3 BoneMatrices[MAX_SKINNING_BONES],
        uniform float4x3 BoneMatrices2[MAX_SKINNING_BONES]
        )
{
    float3 pos, normal;
    Skin(pos,normal,vin.position,vin.normal.xyz,vin.indices,vin.weight,BoneMatrices);
    float3 pos2;
    SkinPositionOnly(pos2,vin.position,vin.indices,vin.weight,BoneMatrices2);

    float3x4 prev, cur;
    cur[0]=VectorParam2;
    cur[1]=VectorParam3;
    cur[2]=VectorParam4;
    prev[0]=VectorParam5;
    prev[1]=VectorParam6;
    prev[2]=VectorParam7;

    float3 newPos=mul(cur,float4(pos,1));
    float3 oldPos=mul(prev,float4(pos2,1));
    
    float3 newNormal=mul((float3x3)cur,normal);
    
    float3 dir=(newPos-oldPos).xyz;
    float dotVal=dot(dir,newNormal);
    
    float3 finalPos=dotVal>0?newPos:oldPos;
    float alpha=dotVal>0?1:0;
    
    vout.position=mul(ModelViewProjMatrix,float4(finalPos,1));
    
    vout.uv0 = vin.uv0;
    float blend=alpha;
    
    float3 clr=dotVal>0?float3(0.044,0.008,0.00):float3(1,1,1);
    vout.diffuse = float4(clr*blend,0.2*(1-blend))*Blend.x;
}

half4 main(in Vert2Frag In, 
            uniform sampler2D Texture0
            ) : COLOR
{
    half4 src=In.diffuse;
    return src;
}


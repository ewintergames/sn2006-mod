// #class Object

struct App2Vert
{
    float4 position     : POSITION;
    float2 uv0          : TEXCOORD0;
    float4 weight       : BLENDWEIGHT;
    float4 indices      : BLENDINDICES;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float2 uv0          : TEXCOORD0;
};

#include "Skinning.HLSLinc"

// TextureScroll = 1 0 0 0

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix, uniform float FrameTime, uniform float4 VectorParam2_TextureScroll,
        uniform float4x3 BoneMatrices[MAX_SKINNING_BONES]
        )
{
    float3 pos;
    SkinPositionOnly(pos, vin.position, vin.indices, vin.weight, BoneMatrices);

    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
    vout.uv0 = vin.uv0+float2(frac(VectorParam2_TextureScroll.xy*FrameTime));
}

// #default Color = 1 1 1 1

half4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform float Blend, uniform half4 VectorParam1_Color) : COLOR
{
    half4 src=tex2D(Texture0,In.uv0);
    src*=VectorParam1_Color;
    src.w*=Blend;
    return src;
}

// #class Object

struct App2Vert
{
    float4 position     : POSITION;
    float2 uv           : TEXCOORD0;
    float4 weight       : BLENDWEIGHT;
    float4 indices      : BLENDINDICES;
	
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
	float2 uv           : TEXCOORD0;
	float fog				: FOG;
};

#define MAX_LIGHTS	3

#include "Skinning.HLSLinc"
#include "lighting.cginc"
#include "lighting2.cginc"

void vertex(in App2Vert vin, out Vert2Frag vout, uniform float4 VectorParam0_Color,
		uniform half4 EyeInObjectSpace,
        uniform half4 FogParams,
        uniform float4x4 ModelViewProjMatrix, uniform float4x3 BoneMatrices[MAX_SKINNING_BONES]
        )
{
    float3 pos;
    SkinPositionOnly(pos,vin.position,vin.indices,vin.weight,BoneMatrices);
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
    vout.diffuse = VectorParam0_Color;
    vout.uv=vin.uv;
	vout.fog=1 - fogFactor(pos,EyeInObjectSpace.xyz,FogParams);
}

float4 main(in Vert2Frag In, 
			uniform sampler2D Texture0,
			uniform float4 BlendFactors
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv);
    float4 color=float4(src.xyz*In.diffuse.xyz,src.w*BlendFactors.x+BlendFactors.y);
    return color;
}

// shader model 1.1

void vertex1_1(in App2Vert vin, out Vert2Frag vout, uniform float4 VectorParam0_Color,
		uniform half4 EyeInObjectSpace,
        uniform half4 FogParams,
        uniform float4x4 ModelViewProjMatrix, uniform float4x3 BoneMatrices[MAX_SKINNING_BONES]
        )
{
    float3 pos;
    SkinPositionOnly(pos,vin.position,vin.indices,vin.weight,BoneMatrices);
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
    vout.diffuse = VectorParam0_Color;
    vout.uv=vin.uv;
	vout.fog=1 - fogFactor(pos,EyeInObjectSpace.xyz,FogParams);
}

float4 main1_1(in Vert2Frag In, 
			uniform sampler2D Texture0,
			uniform float4 BlendFactors
            ) : COLOR
{
	float2 bf = saturate(BlendFactors.xy);
    float4 src=tex2D(Texture0,In.uv);
    float4 color=float4(src.xyz*In.diffuse.xyz,src.w*bf.x+bf.y);
    return color;
}

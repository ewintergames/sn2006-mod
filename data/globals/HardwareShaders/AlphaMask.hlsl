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
    float  fog          : FOG;
    float2 uv0          : TEXCOORD0;
	float2 amask		: TEXCOORD1;
};

#define MAX_LIGHTS    4

#include "lighting.cginc"
#include "lighting2.cginc"

// #invertalpha
// #default AlphaMaskTiles = 1 1 0 0

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 Ambient,
        uniform float4 FogParams,
        uniform float4 VectorParam0_AlphaMaskTiles
        )
{
    float4 pos=vin.position;

    // no lighting
    vout.position = mul(ModelViewProjMatrix, pos);
    vout.uv0 = vin.uv0;
	vout.amask = vin.uv0 * VectorParam0_AlphaMaskTiles.xy;
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0,
			uniform sampler2D Texture2_Background,
			uniform sampler2D Texture3_AlphaMask,
            uniform float Blend
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv0);
	float4 bg = tex2D(Texture2_Background, In.uv0);
	float4 alpha = tex2D(Texture3_AlphaMask, In.amask);
	src=src*alpha.w + bg;
    return src;
}


struct Vert2Frag1_1
{
    float4 position     : POSITION;
    float fog          : FOG;
    float2 uv0          : TEXCOORD0;
	float2 uv1		   : TEXCOORD1;
	float2 uv2		   : TEXCOORD2;
	float2 amask		: TEXCOORD3;
};


void vertex1_1(in App2Vert vin, out Vert2Frag1_1 vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 Ambient,
        uniform float4 FogParams,
        uniform float4 VectorParam0_AlphaMaskTiles
        )
{
    float4 pos=vin.position;

    // no lighting
    vout.position = mul(ModelViewProjMatrix, pos);
    vout.uv0 = vin.uv0;
	vout.uv1 = vin.uv0;
	vout.uv2 = vin.uv0;
	vout.amask = vin.uv0 * VectorParam0_AlphaMaskTiles.xy;
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}

float4 main1_1(in Vert2Frag1_1 In, 
            uniform sampler2D Texture0,
			uniform sampler2D Texture2_Background,
			uniform sampler2D Texture3_AlphaMask,
            uniform float Blend
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv0);
	float4 bg = tex2D(Texture2_Background, In.uv2);
	float4 alpha = tex2D(Texture3_AlphaMask, In.amask);
	src=src*alpha.w + bg;
	src.w*=1-Blend;
    return src;
}


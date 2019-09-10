// #class Terrain
// #Lightmap

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float2 uv0          : TEXCOORD0;
    float2 uv1          : TEXCOORD1;
    float2 uv2          : TEXCOORD2;
    float4 mask         : COLOR0;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
    float3 mask         : COLOR1;
    float2 uv0          : TEXCOORD0;
    float2 uv1          : TEXCOORD1;
    float2 uv2          : TEXCOORD2;
    float2 noise1UV     : TEXCOORD3;
    float2 noise2UV     : TEXCOORD4;
	float fog				: FOG;
};

#define MAX_LIGHTS    2
#include "lighting.cginc"
#include "lighting2.cginc"
#include "spec.cginc"

#define PI  3.1415926535897932384626433832795

// #default Noise1 = 0.1543543  0.7         1.646432    0
// #default Noise2 = -0.92442    0.03235432   1.12432     0

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4 Ambient,
        uniform float4 FrameTime,
        uniform float4 VectorParam1_Noise1,
        uniform float4 VectorParam2_Noise2,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS]
        )
{
    int i;
    // lighting

    vout.position = mul(ModelViewProjMatrix, vin.position);
    float4 color=vertexDiffuse(vin.position.xyz,vin.normal.xyz,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    vout.diffuse=color;
    vout.uv0 = vin.uv0;
    vout.uv1 = vin.uv1;
    vout.uv2 = vin.uv2;
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
    
    vout.mask = vin.mask.www;
    vout.noise1UV = vin.uv1*VectorParam1_Noise1.z + frac(VectorParam1_Noise1.xy*FrameTime);
    vout.noise2UV = vin.uv1*VectorParam2_Noise2.z + frac(VectorParam2_Noise2.xy*FrameTime);
}

// #default AdditiveColor = 1 1 1 0
// #default Texture3_Noise = sfx\firenoise.tga
// #default HighlightScale = 2

half4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture1, uniform sampler2D Texture2,
            uniform sampler2D Texture3_Noise,
            uniform half FloatParam7_HighlightScale,
            uniform half4 VectorParam7_AdditiveColor
            ) : COLOR
{
    half4 src1=half4(tex2D(Texture0,In.uv0));
    half4 src2=half4(tex2D(Texture2,In.uv2));
    half4 scaledSrc1=src1*(1-In.mask.x);
    half4 src=scaledSrc1+src2*In.mask.x;
    half3 lightmap=half3(tex2D(Texture1,In.uv1).xyz);
    
    half4 diffuse=half4(saturate(lightmap+In.diffuse.xyz),1);
    src=src*diffuse;
    
    half4 noise1=tex2D(Texture3_Noise,In.noise1UV);
    half4 noise2=tex2D(Texture3_Noise,In.noise2UV);
    half4 noise=noise1*noise2;
    noise=saturate(noise*FloatParam7_HighlightScale);
    noise=noise*noise;
    src+=(VectorParam7_AdditiveColor*noise)*scaledSrc1.w;
    return src;
}

// #class Object
// #NoFog

struct App2Vert
{
    float4 position     : POSITION;
    float2 uv0          : TEXCOORD0;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float2 uv0          : TEXCOORD0;
    float2 noise1UV     : TEXCOORD4;
    float2 noise2UV     : TEXCOORD5;
    float4 color        : TEXCOORD7;
};

#include "lighting.cginc"

// #default AdditiveColor = 1 1 1 1
// #default Map1 = 1 0 1 0
// #default Map2 = 0 1 1 0

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float FrameTime,
        uniform float4 VectorParam2_Map1,
        uniform float4 VectorParam3_Map2,
        uniform float4 VectorParam7_AdditiveColor,
        uniform float2 Blend
        )
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    float2 map1=vin.uv0*VectorParam2_Map1.z+VectorParam2_Map1.xy*FrameTime;
    float2 map2=vin.uv0*VectorParam3_Map2.z+VectorParam3_Map2.xy*FrameTime;
    
    vout.uv0 = vin.uv0;
    vout.noise1UV=map1;
    vout.noise2UV=map2;
    
    float fog=1-fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
    vout.color = float4(1,1,1, Blend.x*fog)*VectorParam7_AdditiveColor;
}

// #default Texture1_Noise = sfx\firenoise.tga
// #default HighlightScale = 2

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0,
            uniform float FloatParam7_HighlightScale,        
            uniform sampler2D Texture1_Noise
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv0);

    half3 noise1=tex2D(Texture1_Noise,In.noise1UV);
    half3 noise2=tex2D(Texture1_Noise,In.noise2UV);
    half3 noise=noise1*noise2;
    noise*=FloatParam7_HighlightScale;

    noise=noise*noise;
    noise=noise*noise;

    src.xyz*=noise;
    src=src*In.color;
    return src;
    return src;
}

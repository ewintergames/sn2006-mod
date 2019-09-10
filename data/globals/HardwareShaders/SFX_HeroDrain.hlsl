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
    float4 color        : COLOR0;
};

#include "lighting.cginc"

// #default Noise1 = 0.1543543  0.7         20    0
// #default Noise2 = -0.92442    0.03235432   16     0
// #default EffectPosition = 1
// #default EffectClampScale = 16

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float FrameTime,
        uniform float4 VectorParam1_Noise1,
        uniform float4 VectorParam2_Noise2,
        uniform float FloatParam1_EffectPosition,
        uniform float FloatParam2_EffectClampScale,
        uniform float2 Blend
        )
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.uv0 = vin.uv0;
    vout.noise1UV = vin.uv0*VectorParam1_Noise1.z + frac(VectorParam1_Noise1.xy*FrameTime);
    vout.noise2UV = vin.uv0*VectorParam2_Noise2.z + frac(VectorParam2_Noise2.xy*FrameTime);
    
    float clampDown = saturate(FloatParam2_EffectClampScale*(vin.uv0.y+saturate(FloatParam1_EffectPosition)-1));
    float clampUp = saturate(FloatParam2_EffectClampScale*(1-vin.uv0.y-saturate(FloatParam1_EffectPosition-1)));
    float intensity = clampDown*clampUp;
    
    float fog=1-fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
    vout.color = float4(intensity.xxx, Blend.x*fog);
}

// #default AdditiveColor = 1 1 1 0
// #default Texture1_Noise = sfx\firenoise.tga
// #default ExtraColor = 0 0 0 0
// #default HighlightScale = 2

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0,
            uniform sampler2D Texture1_Noise,
            uniform float4 VectorParam3_ExtraColor,
            uniform float FloatParam7_HighlightScale, uniform float4 VectorParam7_AdditiveColor
            ) : COLOR
{
    float4 src=float4(VectorParam3_ExtraColor.xyz,tex2D(Texture0,In.uv0).x);
    float noiseMask=src.w;

    half3 noise1=tex2D(Texture1_Noise,In.noise1UV);
    half3 noise2=tex2D(Texture1_Noise,In.noise2UV);
    half3 noise=noise1*noise2;
    noise=saturate(noise*FloatParam7_HighlightScale);
    src.xyz=saturate(src.xyz+(VectorParam7_AdditiveColor.xyz*noise)*noiseMask);
    
    src=float4(src.xyz*In.color.xyz,In.color.w);
    return src;
}

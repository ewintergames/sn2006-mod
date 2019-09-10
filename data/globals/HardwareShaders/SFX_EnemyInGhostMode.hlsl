// #class Object
// #NoFog

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float4 tangent      : TANGENT;
    float2 uv0          : TEXCOORD0;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float2 uv0          : TEXCOORD0;
    float3 eyeVector    : TEXCOORD2;        // in tangent space
    float blend         : COLOR1;
};

#include "lighting.cginc"

#define MAX_LIGHTS    4

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4 Ambient,
        uniform float FrameTime,
        uniform float2 Blend
        )
{
    int i;
    // lighting

    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.uv0 = vin.uv0;

    float3x3 objToTangentSpace;
    ModelToTangentMatrix(vin.normal, vin.tangent, objToTangentSpace);
    
    float3 eyeV=normalize(EyeInObjectSpace.xyz-vin.position.xyz);
    vout.eyeVector=mul(objToTangentSpace,eyeV);
    vout.blend = Blend.x*(1-fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams));
}

// #default EyeFactorExponent = 16
// #default Color = 1 1 1 1
// #default Texture3_Lookup = FSE\Sepia_NoCompressionClamp.tga


float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture2_NormalMap, uniform sampler2D Texture3_Lookup,
            uniform half FloatParam2_EyeFactorExponent, uniform half4 VectorParam1_Color
            ) : COLOR
{
//    half4 src=tex2D(Texture0,In.uv0);

    half3 normal=tex2D(Texture2_NormalMap,In.uv0).xyz;
    normal=normalize(normal-0.5);
    
    half3 eyeV=normalize(In.eyeVector);
    half eyeDot=saturate(dot(eyeV,normal));
    half eyeFactor=pow(eyeDot, FloatParam2_EyeFactorExponent);
    half3 col=tex2D(Texture3_Lookup,half2(eyeFactor,0.5));
    
    col*=VectorParam1_Color.xyz;
    
//    src.w*=In.blend*eyeFactor;
    half4 src=half4(col,In.blend);
    return src;
}

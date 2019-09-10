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
    float4 majorDiffuse : COLOR0;
    float3 minorDiffuse : COLOR1;
    float2 uv0          : TEXCOORD0;
    float4 specular     : TEXCOORD1;
    float3 lightVector  : TEXCOORD2;        // in tangent space
    float3 halfAngle    : TEXCOORD3;        // in tangent space
};

#define MAX_LIGHTS    4

#include "lighting.cginc"
#include "lighting2.cginc"

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4 Ambient,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS]
        )
{
    int i;
    // lighting

    vout.position = mul(ModelViewProjMatrix, vin.position);
    
    vout.majorDiffuse=vertexDiffuseAndSpecularSingleLight(vin.position.xyz,vin.normal,LightLocalPositionTable[0],LightColorTable[0],LightAttenuationTable[0],vout.specular);
    float4 color=Ambient;
    for(i=1;i<MAX_LIGHTS;++i)
        color+=vertexDiffuseSingleLight(vin.position.xyz,vin.normal,LightLocalPositionTable[i],LightColorTable[i],LightAttenuationTable[i]);
    vout.minorDiffuse=color.xyz;
    
    vout.uv0 = vin.uv0;

    float3x3 objToTangentSpace;
    ModelToTangentMatrix(vin.normal, vin.tangent, objToTangentSpace);
    
    // in object space
    float3 lightVector = normalize(LightLocalPositionTable[0].xyz-vin.position.xyz);
    float3 halfAngle = normalize(lightVector + normalize(EyeInObjectSpace.xyz-vin.position.xyz));
    
    vout.lightVector = mul(objToTangentSpace,lightVector);
    vout.halfAngle = mul(objToTangentSpace,halfAngle);
    vout.majorDiffuse.w = fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}

// #default SpecularScale = 1
// #default SpecularAdd = 0
// #default Texture2_NormalMap = NormalMap\normalgladka.tga
// #default Texture3_SpecularLookup = Specular\Standard_NoCompressionClamp.tga

half4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture2_NormalMap,
            uniform sampler2D Texture3_SpecularLookup,
            uniform half FloatParam0_SpecularScale, uniform half FloatParam1_SpecularAdd,
            uniform half2 Blend
            ) : COLOR
{
    half4 src=half4(tex2D(Texture0,In.uv0));
    half3 bumpNormal=2*(half4(tex2D(Texture2_NormalMap,In.uv0)).xyz-0.5.xxx);
    
    half selfShadowFactor=saturate(dot(bumpNormal,In.lightVector));
    half4 diffuse=saturate(half4(In.minorDiffuse+In.majorDiffuse.xyz*selfShadowFactor,Blend.y));

    half specularFactor=saturate(dot(bumpNormal,In.halfAngle));
    half4 spec=half4(tex2D(Texture3_SpecularLookup, half2(specularFactor,0)));
    spec=half4(spec.xyz*In.specular.xyz*(src.w*FloatParam0_SpecularScale+FloatParam1_SpecularAdd),1-Blend.y);
    
    src=src*diffuse+spec;
    src*=Blend.x;
    src=fogHalfAdditive(src,In.majorDiffuse.w);
    return src;
}

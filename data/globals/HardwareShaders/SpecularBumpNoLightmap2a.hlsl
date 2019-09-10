// #class Object

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
	float fog				: FOG;
};

#define MAX_LIGHTS    4

#include "lighting.cginc"
#include "lighting2.cginc"
#include "spec.cginc" 

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4 Ambient,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS],
        uniform AppLightIn SpecularSource
        )
{
    int i;
    // lighting

    vout.position = mul(ModelViewProjMatrix, vin.position);
    
    vout.majorDiffuse=vertexDiffuseSingleLight(vin.position.xyz,vin.normal,LightLocalPositionTable[0],LightColorTable[0],LightAttenuationTable[0]);
    vout.specular=specularAttenuation(SpecularSource,vin.position.xyz); 
    vout.specular.w=0;
    float4 color=Ambient;
    for(i=1;i<MAX_LIGHTS;++i)
        color+=vertexDiffuseSingleLight(vin.position.xyz,vin.normal,LightLocalPositionTable[i],LightColorTable[i],LightAttenuationTable[i]);
    vout.minorDiffuse=color.xyz;
    
    vout.uv0 = vin.uv0;

    float3x3 objToTangentSpace;
    ModelToTangentMatrix(vin.normal, vin.tangent, objToTangentSpace);
    
    // in object space
    float3 lightVector = normalize(LightLocalPositionTable[0]-vin.position.xyz);
    float3 halfAngle = normalize(lightVector + normalize(EyeInObjectSpace.xyz-vin.position.xyz));
    
    vout.lightVector = mul(objToTangentSpace,lightVector);
    vout.halfAngle = mul(objToTangentSpace,halfAngle);
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}

// #default SpecularScale = 1
// #default SpecularAdd = 0
// #default Texture2_NormalMap = NormalMap\normalgladka.tga
// #default Texture3_SpecularLookup = Specular\Standard_NoCompressionClamp.tga

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture2_NormalMap,
            uniform sampler2D Texture3_SpecularLookup,
            uniform float FloatParam0_SpecularScale, uniform float FloatParam1_SpecularAdd,
            uniform float2 Blend
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv0);
    float3 bumpNormal=2*(tex2D(Texture2_NormalMap,In.uv0).xyz-0.5.xxx);
    
    float selfShadowFactor=saturate(dot(bumpNormal,In.lightVector));
    float4 diffuse=saturate(float4(In.minorDiffuse+In.majorDiffuse.xyz*selfShadowFactor,Blend.y));

    float specularFactor=saturate(dot(bumpNormal,In.halfAngle));
    float4 spec=tex2D(Texture3_SpecularLookup, float2(specularFactor,0));
    spec=float4(spec.xyz*In.specular.xyz*(src.w*FloatParam0_SpecularScale+FloatParam1_SpecularAdd),1-Blend.y);
    
    src=src*diffuse+spec;
    src.w*=Blend.x;
    return src;
}

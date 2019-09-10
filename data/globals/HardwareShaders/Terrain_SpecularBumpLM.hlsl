// #class Terrain
// #Lightmap

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float2 uv0          : TEXCOORD0;
    float2 uv1          : TEXCOORD1;
    float4 tangent      : TANGENT;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
    float3 specular     : COLOR1;
    float2 uv0          : TEXCOORD0;
    float2 uv1          : TEXCOORD1;
    float3 lightVector  : TEXCOORD2;        // in tangent space
    float3 halfAngle    : TEXCOORD3;        // in tangent space
	float fog				: FOG;
};

#define MAX_LIGHTS    2
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
    vout.specular=specularAttenuation(SpecularSource,vin.position.xyz);
    float4 color=vertexDiffuse(vin.position.xyz,vin.normal.xyz,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    vout.diffuse=color;
    vout.uv0 = vin.uv0;
    vout.uv1 = vin.uv1;

    float3x3 objToTangentSpace;
    ModelToTangentMatrix(vin.normal, vin.tangent, objToTangentSpace);
    
    // in object space
    float3 lightVector = normalize(SpecularSource.PositionInObjectSpace.xyz-vin.position.xyz);
    float3 halfAngle = normalize(lightVector + normalize(EyeInObjectSpace.xyz-vin.position.xyz));
    
    vout.lightVector = mul(objToTangentSpace,lightVector);
    vout.halfAngle = mul(objToTangentSpace,halfAngle);
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}

// #default SpecularScale = 1
// #default SpecularAdd = 0
// #default SpecularExponent = 512
// #default LightmapDarkness = 1

half4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform sampler2D Texture2,
            uniform half FloatParam2_SpecularExponent,
            uniform half FloatParam0_SpecularScale, uniform half FloatParam1_SpecularAdd,
			uniform half FloatParam3_LightmapDarkness,
            uniform float2 Blend
            ) : COLOR
{
    half4 src=half4(tex2D(Texture0,In.uv0));
    half3 lightmap=half3(tex2D(Texture1,In.uv1).xyz);
    
    half3 bumpNormal=2*(half3(tex2D(Texture2,In.uv0).xyz)-0.5.xxx);
    bumpNormal=normalize(bumpNormal);
    
//    half selfShadowFactor=saturate(dot(bumpNormal,In.lightVector));
    half4 diffuse=half4(saturate(lightmap+In.diffuse.xyz),Blend.y);
    
    half specularFactor=saturate(dot(bumpNormal,normalize(In.halfAngle)));
    half3 spec=pow(specularFactor,FloatParam2_SpecularExponent).xxx;

	half3 scaledLM = lerp(half3(1,1,1),lightmap, FloatParam3_LightmapDarkness);
    spec*=In.specular*saturate(scaledLM + In.diffuse.xyz);
    spec*=(src.w*FloatParam0_SpecularScale+FloatParam1_SpecularAdd);
    
    src=src*diffuse+half4(spec,1-Blend.y);
    src.w*=Blend.x;
    return src;
}

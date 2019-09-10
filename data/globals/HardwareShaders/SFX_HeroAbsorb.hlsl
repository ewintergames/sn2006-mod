// #class Object
// #NoFog

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float4 tangent      : TANGENT;
    float2 uv0          : TEXCOORD0;
    float4 weight       : BLENDWEIGHT;
    float4 indices      : BLENDINDICES;
};

struct Vert2Frag
{
    half4 position     : POSITION;
    half2 uv0          : TEXCOORD0;
    half2 noise1UV     : TEXCOORD1;
    half2 noise2UV     : TEXCOORD2;
    half4 light0       : TEXCOORD3;
    half4 light1       : TEXCOORD4;
    half4 light2       : TEXCOORD5;
    half3 light0HalfAngle : TEXCOORD6;
    half3 light1HalfAngle : TEXCOORD7;
    half blend         : COLOR1;
    half3 specularAttenuation  : COLOR0;
};

#define MAX_LIGHTS    3

#include "lighting.cginc"
#include "lighting2.cginc"
#include "Skinning.HLSLinc"

#define BW float4(0.239,0.686,0.075,0)


// #default Noise1 = 0.3       0.183         4    0
// #default Noise2 = -0.21     0.33          4    0
// #default DiffuseMultiplier = 1
// #default SpecularScale = 1

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 FogParams,
        uniform float FrameTime,
        uniform float4 VectorParam1_Noise1,
        uniform float4 VectorParam2_Noise2,
        uniform float FloatParam2_DiffuseMultiplier,
        uniform half FloatParam4_SpecularScale,
        uniform float4 EyeInObjectSpace,
        uniform float2 Blend,
        uniform float4x3 BoneMatrices[MAX_SKINNING_BONES],
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS]
        )
{
    float3 pos, normal;
    float4 tangent;
    SkinTangent(pos,normal,tangent,vin.position,vin.normal.xyz,vin.tangent,vin.indices,vin.weight,BoneMatrices);

    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
    vout.uv0 = vin.uv0;
    
    float3x3 objToTangentSpace;
    ModelToTangentMatrix(normal, tangent, objToTangentSpace);

    half3 light0Dir=normalize(LightLocalPositionTable[0].xyz-pos);
    half3 light1Dir=normalize(LightLocalPositionTable[1].xyz-pos);
    half3 light2Dir=normalize(LightLocalPositionTable[2].xyz-pos);

    float l0Att=ooLightAttenuationDirect(LightLocalPositionTable[0].xyz,LightAttenuationTable[0],pos);
    float l1Att=ooLightAttenuationDirect(LightLocalPositionTable[1].xyz,LightAttenuationTable[1],pos);
    float l2Att=ooLightAttenuationDirect(LightLocalPositionTable[2].xyz,LightAttenuationTable[2],pos);

    vout.light0 = half4(mul(objToTangentSpace,light0Dir),FloatParam2_DiffuseMultiplier*l0Att);
    vout.light1 = half4(mul(objToTangentSpace,light1Dir),FloatParam2_DiffuseMultiplier*l1Att);
    vout.light2 = half4(mul(objToTangentSpace,light2Dir),FloatParam2_DiffuseMultiplier*l2Att);

    float3 toEyeVector = normalize(EyeInObjectSpace.xyz-pos);
    float3 halfAngle0 = normalize(light0Dir+toEyeVector);
    float3 halfAngle1 = normalize(light1Dir+toEyeVector);

    vout.light0HalfAngle.xyz = mul(objToTangentSpace,halfAngle0);
    vout.light1HalfAngle.xyz = mul(objToTangentSpace,halfAngle1);
    
    vout.specularAttenuation = saturate(half3(l0Att,l1Att,l2Att))*FloatParam4_SpecularScale;

    float2 map1=vin.uv0*VectorParam1_Noise1.z+VectorParam1_Noise1.xy*FrameTime;
    float2 map2=vin.uv0*VectorParam2_Noise2.z+VectorParam2_Noise2.xy*FrameTime;
    vout.noise1UV=map1;
    vout.noise2UV=map2;
    
    vout.blend = Blend.x*(1-fogFactor(pos,EyeInObjectSpace.xyz,FogParams));
}

// #default Texture1_Noise = sfx\firenoise.tga
// #default HighlightScale = 2
// #default SpecularExponent = 32

// #default Texture4_Vains = Characters\Hero_Absorb_01.tga
// #default VainColor = 1 0 0 0

#define BW float4(0.239,0.686,0.075,0)

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0,
            uniform sampler2D Texture1_Noise, uniform sampler2D Texture2_NormalMap,
            uniform sampler2D Texture4_Vains,
            uniform half4 VectorParam4_VainColor,
            uniform half FloatParam7_HighlightScale, 
            uniform half FloatParam3_SpecularExponent,
            uniform half4 Ambient,
            uniform float4 LightColorTable[MAX_LIGHTS]
            ) : COLOR
{
    half4 textureColor=tex2D(Texture0, In.uv0);
    half3 normal=HQNormalMap(Texture2_NormalMap,In.uv0);
    
    half3 light=Ambient.xyz;
    light+=LightColorTable[0].xyz*saturate(In.light0.w*dot(normal,normalize(In.light0.xyz)));
    light+=LightColorTable[1].xyz*saturate(In.light1.w*dot(normal,normalize(In.light1.xyz)));
    light+=LightColorTable[2].xyz*saturate(In.light2.w*dot(normal,normalize(In.light2.xyz)));
    
    half3 halfAngle0=normalize(In.light0HalfAngle.xyz);
    half3 halfAngle1=normalize(In.light1HalfAngle.xyz);
    half2 specularFactor=saturate(half2(dot(normal,halfAngle0),dot(normal,halfAngle1)));
    specularFactor=pow(specularFactor,FloatParam3_SpecularExponent);
    specularFactor*=In.specularAttenuation;
    
    half3 specularColor=LightColorTable[0].xyz*specularFactor.x + LightColorTable[1].xyz*specularFactor.y;
    
    half3 vains=tex2D(Texture4_Vains,In.uv0).xyz;
    half3 noise1=tex2D(Texture1_Noise,In.noise1UV);
    half3 noise2=tex2D(Texture1_Noise,In.noise2UV);
    half3 noise=noise1*noise2;
    noise*=noise;
    noise*=FloatParam7_HighlightScale;
    half3 vainColor=vains*noise*VectorParam4_VainColor.xyz;

    half3 col=textureColor.xyz*light+ specularColor*textureColor.w + vainColor;
    
    half4 src=half4(col,In.blend);
    return src;
    
}

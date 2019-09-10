// #class Object

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
    half4 position        : POSITION;
    half2 uv0             : TEXCOORD0;
    half4 light0          : TEXCOORD1;
    half4 light1          : TEXCOORD2;
    half4 light2          : TEXCOORD3;
    half3 light0HalfAngle : TEXCOORD4;
    half3 light1HalfAngle : TEXCOORD5;
    half3 light2HalfAngle : TEXCOORD6;
    half3 reflVector      : TEXCOORD7;
    half  fog             : FOG;
    half3 specularAttenuation  : COLOR0;
};

#define MAX_LIGHTS  3

#include "lighting.cginc"
#include "lighting2.cginc"

#include "Skinning.HLSLinc"

// #default DiffuseMultiplier = 2
// #default SpecularScale = 1

#if VS_VER_MAJOR >= 2
void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform half4x4 ModelViewProjMatrix,
        uniform half4 EyeInObjectSpace,
        uniform half4 FogParams,
        uniform half FloatParam2_DiffuseMultiplier,
        uniform half FloatParam4_SpecularScale,
        uniform half4 LightLocalPositionTable[MAX_LIGHTS],
        uniform half4 LightAttenuationTable[MAX_LIGHTS],
        uniform float4x3 BoneMatrices[MAX_SKINNING_BONES]
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
    
    float l0Att=ooLightAttenuationDirect(LightLocalPositionTable[0].xyz, LightAttenuationTable[0],pos);
    float l1Att=ooLightAttenuationDirect(LightLocalPositionTable[1].xyz, LightAttenuationTable[1],pos);
    float l2Att=ooLightAttenuationDirect(LightLocalPositionTable[2].xyz, LightAttenuationTable[2],pos);
    
    vout.light0 = half4(mul(objToTangentSpace,light0Dir),FloatParam2_DiffuseMultiplier*l0Att);
    vout.light1 = half4(mul(objToTangentSpace,light1Dir),FloatParam2_DiffuseMultiplier*l1Att);
    vout.light2 = half4(mul(objToTangentSpace,light2Dir),FloatParam2_DiffuseMultiplier*l2Att);

    float3 toEyeVector = normalize(EyeInObjectSpace.xyz-pos);
    float3 halfAngle0 = normalize(light0Dir+toEyeVector);
    float3 halfAngle1 = normalize(light1Dir+toEyeVector);
    float3 halfAngle2 = normalize(light2Dir+toEyeVector);

    vout.light0HalfAngle.xyz = mul(objToTangentSpace,halfAngle0);
    vout.light1HalfAngle.xyz = mul(objToTangentSpace,halfAngle1);
    vout.light2HalfAngle.xyz = mul(objToTangentSpace,halfAngle2);
    vout.reflVector = reflect(toEyeVector,normal);
    
    vout.specularAttenuation = saturate(half3(l0Att,l1Att,l2Att))*FloatParam4_SpecularScale;
    vout.fog=1 - fogFactor(pos,EyeInObjectSpace.xyz,FogParams);
}
#endif

// #default Texture2_NormalMap = NormalMap\normalgladka.tga
// #default SpecularExponent = 32
// #default ReflectionIntensity = 0.5
// #default Texture3_EnvMap = CubeMaps\Sample_CubeMap.tga

#if PS_VER_MAJOR >= 2
half4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture2_NormalMap,
            uniform samplerCUBE Texture3_EnvMap,
            uniform half2 Blend,
            uniform half4 Ambient,
            uniform half4 LightColorTable[MAX_LIGHTS],
            uniform half FloatParam3_SpecularExponent,
            uniform half FloatParam5_ReflectionIntensity
            ) : COLOR
{
    half4 textureColor=tex2D(Texture0,In.uv0);
    half3 normal=HQNormalMap(Texture2_NormalMap,In.uv0);
    
    half3 light=Ambient.xyz;
    light+=LightColorTable[0].xyz*saturate(In.light0.w*dot(normal,normalize(In.light0.xyz)));
    light+=LightColorTable[1].xyz*saturate(In.light1.w*dot(normal,normalize(In.light1.xyz)));
    light+=LightColorTable[2].xyz*saturate(In.light2.w*dot(normal,normalize(In.light2.xyz)));
    
    half3 halfAngle0=normalize(In.light0HalfAngle.xyz);
    half3 halfAngle1=normalize(In.light1HalfAngle.xyz);
    half3 halfAngle2=normalize(In.light2HalfAngle.xyz);
    half3 specularFactor=saturate(half3(dot(normal,halfAngle0),dot(normal,halfAngle1),dot(normal,halfAngle2)));
    specularFactor=pow(specularFactor,FloatParam3_SpecularExponent);
    specularFactor*=In.specularAttenuation;

    half3 reflection=texCUBE(Texture3_EnvMap,In.reflVector).xyz*FloatParam5_ReflectionIntensity;
        
    half3 specularColor=LightColorTable[0].xyz*specularFactor.x + LightColorTable[1].xyz*specularFactor.y + LightColorTable[2].xyz*specularFactor.z;
    half4 color=half4(textureColor.xyz*light + (specularColor+reflection)*textureColor.w,Blend.x);
    return color;
}
#endif

struct Vert2Frag1_1
{
    float4 position     : POSITION;
    float2 uv           : TEXCOORD0;
    float4 diffuse      : COLOR0;
	float fog				: FOG;
};

void vertex1_1(in App2Vert vin, out Vert2Frag1_1 vout,
        uniform float4x4 ModelViewProjMatrix, 
		uniform float4x3 BoneMatrices[MAX_SKINNING_BONES],
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4 Ambient,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS]
        )
{
    float3 pos, nor;
    Skin(pos,nor,vin.position,vin.normal,vin.indices,vin.weight,BoneMatrices);
    
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
    
    float4 color=vertexDiffuse(pos,nor,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    vout.diffuse = float4(color.xyz,1);
    vout.uv = vin.uv0;
	vout.fog=1 - fogFactor(pos,EyeInObjectSpace.xyz,FogParams);
}

float4 main1_1(in Vert2Frag1_1 In, uniform sampler2D Texture0, uniform float4 BlendFactors) : COLOR
{
	float2 bf = saturate(BlendFactors.xy);
    float4 src=tex2D(Texture0,In.uv);
    float4 color=float4(src.xyz*In.diffuse.xyz,src.w*bf.x+bf.y);
    return color;
}


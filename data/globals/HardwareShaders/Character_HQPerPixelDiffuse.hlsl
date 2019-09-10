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
    half4 position     : POSITION;
    half2 uv0          : TEXCOORD0;
    half4 light0       : TEXCOORD4;
    half4 light1       : TEXCOORD5;
    half4 light2       : TEXCOORD6;
    half4 light3       : TEXCOORD7;
	half	fog		: FOG;
};

#define MAX_LIGHTS  4


#include "lighting.cginc"
#include "lighting2.cginc"

#include "Skinning.HLSLinc"

// #default DiffuseMultiplier = 2

#if VS_VER_MAJOR >= 2
void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform half4x4 ModelViewProjMatrix,
        uniform half4 EyeInObjectSpace,
        uniform half4 FogParams,
        uniform half FloatParam2_DiffuseMultiplier,
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
    half3 light3Dir=normalize(LightLocalPositionTable[3].xyz-pos);
    
    vout.light0 = half4(mul(objToTangentSpace,light0Dir),FloatParam2_DiffuseMultiplier*ooLightAttenuationDirect(LightLocalPositionTable[0].xyz,LightAttenuationTable[0],pos));
    vout.light1 = half4(mul(objToTangentSpace,light1Dir),FloatParam2_DiffuseMultiplier*ooLightAttenuationDirect(LightLocalPositionTable[1].xyz,LightAttenuationTable[1],pos));
    vout.light2 = half4(mul(objToTangentSpace,light2Dir),FloatParam2_DiffuseMultiplier*ooLightAttenuationDirect(LightLocalPositionTable[2].xyz,LightAttenuationTable[2],pos));
    vout.light3 = half4(mul(objToTangentSpace,light3Dir),FloatParam2_DiffuseMultiplier*ooLightAttenuationDirect(LightLocalPositionTable[3].xyz,LightAttenuationTable[3],pos));
    
    vout.fog = 1 - fogFactor(pos,EyeInObjectSpace.xyz,FogParams);
}
#endif
// #default Texture2_NormalMap = NormalMap\normalgladka.tga

#if PS_VER_MAJOR >= 2
half4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture2_NormalMap,
            uniform half4 SceneFogColor, uniform half2 Blend,
            uniform half4 Ambient,
            uniform half4 LightColorTable[MAX_LIGHTS]
            ) : COLOR
{
    half4 textureColor=tex2D(Texture0,In.uv0);
    half3 normal=HQNormalMap(Texture2_NormalMap,In.uv0);
    
    half3 light=Ambient.xyz;
    light+=LightColorTable[0].xyz*saturate(In.light0.w*dot(normal,normalize(In.light0.xyz)));
    light+=LightColorTable[1].xyz*saturate(In.light1.w*dot(normal,normalize(In.light1.xyz)));
    light+=LightColorTable[2].xyz*saturate(In.light2.w*dot(normal,normalize(In.light2.xyz)));
    light+=LightColorTable[3].xyz*saturate(In.light3.w*dot(normal,normalize(In.light3.xyz)));
    
    half4 color=half4(textureColor.xyz*light,Blend.x);
    return color;
}
#endif

struct Vert2Frag1_1
{
    float4 position     : POSITION;
    float2 uv           : TEXCOORD0;
    float4 diffuse      : COLOR0;
	float	fog			: FOG;
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
    vout.uv=vin.uv0;
	vout.fog = 1 - fogFactor(pos,EyeInObjectSpace.xyz,FogParams);
}

float4 main1_1(in Vert2Frag1_1 In, uniform sampler2D Texture0, uniform float4 BlendFactors) : COLOR
{
	float2 bf = saturate(BlendFactors.xy);
    float4 src=tex2D(Texture0,In.uv);
    float4 color=float4(src.xyz*In.diffuse.xyz,src.w*bf.x+bf.y);
    return color;
}

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
    float4 minorDiffuse : COLOR1;
    float2 uv0          : TEXCOORD0;
    float4 specular     : TEXCOORD1;
    float2 lightVector  : TEXCOORD2;        // in tangent space
    float2 halfAngle    : TEXCOORD3;        // in tangent space
	float fog				: FOG;
};

#include "lighting.cginc"

#define MAX_LIGHTS    4

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4 Ambient,
        uniform AppLightIn Lights[MAX_LIGHTS]
        )
{
    int i;
    // lighting for 2 first light
	float4 specular0;
	float4 specular1;

    vout.majorDiffuse=
		diffuseAndSpecular(Lights[0],vin.position.xyz,vin.normal,specular0)
		+ diffuseAndSpecular(Lights[1],vin.position.xyz,vin.normal,specular1);
	
	vout.specular=specular0 + specular1;
	
    float4 color=Ambient;
    for(i=2;i<MAX_LIGHTS;++i)
        color+=diffuse(Lights[i],vin.position.xyz,vin.normal);
    vout.minorDiffuse=color;
    vout.uv0 = vin.uv0;

    float3x3 objToTangentSpace;
    ModelToTangentMatrix(vin.normal, vin.tangent, objToTangentSpace);
    
    // in object space
	// first light
    float3 lightVector = normalize(Lights[0].PositionInObjectSpace.xyz-vin.position.xyz);
    float3 halfAngle = normalize(lightVector + normalize(EyeInObjectSpace.xyz-vin.position.xyz));
	vout.lightVector.x = mul(objToTangentSpace,lightVector).z;
    vout.halfAngle.x = mul(objToTangentSpace,halfAngle).z;
	
	// second light
	lightVector = normalize(Lights[1].PositionInObjectSpace.xyz-vin.position.xyz);
    halfAngle = normalize(lightVector + normalize(EyeInObjectSpace.xyz-vin.position.xyz));
	vout.lightVector.y = mul(objToTangentSpace,lightVector).z;
    vout.halfAngle.y = mul(objToTangentSpace,halfAngle).z;
	
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}

// #default SpecularScale = 1
// #default SpecularAdd = 0
// #default Texture3_SpecularLookup = Specular\Standard_NoCompressionClamp.tga

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, 
            uniform sampler2D Texture3_SpecularLookup,
            uniform float FloatParam0_SpecularScale, uniform float FloatParam1_SpecularAdd,
            uniform float2 Blend
            ) : COLOR
{
    half4 src=tex2D(Texture0,In.uv0);
    half selfShadowFactor=saturate(half(In.lightVector.x)) + saturate(half(In.lightVector.y));
    half specularFactor=saturate(half(In.halfAngle.x)) + saturate(half(In.halfAngle.y));
    half4 diffuse=half4((half3(In.minorDiffuse.xyz)+half3(In.majorDiffuse.xyz)*selfShadowFactor),Blend.y);
    
    half4 spec=half4(tex2D(Texture3_SpecularLookup, half2(specularFactor,0.5)).xyz,0);
    spec=half4(spec.xyz*half3(In.specular.xyz)*(src.w*half(FloatParam0_SpecularScale)+half(FloatParam1_SpecularAdd)),1-Blend.y);
    
    src=src*diffuse+spec;           // alpha is increased by the specular factor
    src.w*=Blend.x;
    return src;
}

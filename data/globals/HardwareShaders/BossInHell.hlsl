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
	float fog				: FOG;
    float2 uv0          : TEXCOORD0;
    float4 specular     : TEXCOORD1;
    float3 lightVector  : TEXCOORD2;        // in tangent space
    float3 halfAngle    : TEXCOORD3;        // in tangent space
    float2 noise1UV     : TEXCOORD4;
    float2 noise2UV     : TEXCOORD5;
};

#include "lighting.cginc"

// #default Noise1 = 0.1543543  0.7         20    0
// #default Noise2 = -0.92442    0.03235432   16     0

#define MAX_LIGHTS    4

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4 Ambient,
        uniform float FrameTime,
        uniform float4 VectorParam1_Noise1,
        uniform float4 VectorParam2_Noise2,
        uniform AppLightIn Lights[MAX_LIGHTS]
        )
{
    int i;
    // lighting

    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.majorDiffuse=diffuseAndSpecular(Lights[0],vin.position.xyz,vin.normal,vout.specular);
    vout.specular.w=0;
    float4 color=Ambient;
    for(i=1;i<MAX_LIGHTS;++i)
        color+=diffuse(Lights[i],vin.position.xyz,vin.normal);
    vout.minorDiffuse=color.xyz;
    vout.uv0 = vin.uv0;
    vout.noise1UV = vin.uv0*VectorParam1_Noise1.z + frac(VectorParam1_Noise1.xy*FrameTime);
    vout.noise2UV = vin.uv0*VectorParam2_Noise2.z + frac(VectorParam2_Noise2.xy*FrameTime);

    float3x3 objToTangentSpace;
    ModelToTangentMatrix(vin.normal, vin.tangent, objToTangentSpace);
    
    // in object space
    float3 lightVector = normalize(Lights[0].PositionInObjectSpace.xyz-vin.position.xyz);
    float3 halfAngle = normalize(lightVector + normalize(EyeInObjectSpace.xyz-vin.position.xyz));
    
    vout.lightVector = mul(objToTangentSpace,lightVector);
    vout.halfAngle = mul(objToTangentSpace,halfAngle);
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}

// #default SpecularScale = 1
// #default SpecularAdd = 0
// #default Texture3_SpecularLookup = Specular\Standard_NoCompressionClamp.tga
// #default AdditiveColor = 1 1 1 0
// #default Texture1_Noise = sfx\firenoise.tga
// #default HighlightScale = 2

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture2_NormalMap,
            uniform sampler2D Texture3_SpecularLookup,
            uniform sampler2D Texture1_Noise,
            uniform float FloatParam7_HighlightScale, uniform float4 VectorParam7_AdditiveColor,
            uniform float FloatParam0_SpecularScale, uniform float FloatParam1_SpecularAdd,
            uniform float2 Blend
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv0);
    float noiseMask=src.w;
    float3 bumpNormal=2*(tex2D(Texture2_NormalMap,In.uv0).xyz-0.5.xxx);
    
    float selfShadowFactor=saturate(dot(bumpNormal,In.lightVector));
    float4 diffuse=float4(In.minorDiffuse+In.majorDiffuse.xyz*selfShadowFactor,Blend.y);

    float specularFactor=saturate(dot(bumpNormal,In.halfAngle));
    float4 spec=tex2D(Texture3_SpecularLookup, float2(specularFactor,0));
    spec=float4(spec.xyz*In.specular.xyz*(src.w*FloatParam0_SpecularScale+FloatParam1_SpecularAdd),1-Blend.y);
    
    src=src*diffuse+spec;
    
    half4 noise1=tex2D(Texture1_Noise,In.noise1UV);
    half4 noise2=tex2D(Texture1_Noise,In.noise2UV);
    half4 noise=noise1*noise2;
    noise=saturate(noise*FloatParam7_HighlightScale);
    noise=noise*noise;
    src=saturate(src+(VectorParam7_AdditiveColor*noise)*noiseMask);
    
    src.w*=Blend.x;
    return src;
}

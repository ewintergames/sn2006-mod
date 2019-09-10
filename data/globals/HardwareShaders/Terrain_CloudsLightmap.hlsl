// #class Terrain
// #Lightmap

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float2 uv0          : TEXCOORD0;
    float2 uv1          : TEXCOORD1;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
    float2 uv0          : TEXCOORD0;
    float2 uv1          : TEXCOORD1;
    float2 cloudsUV     : TEXCOORD2;
	float fog				: FOG;
};

#define MAX_LIGHTS    2
#include "lighting.cginc"
#include "lighting2.cginc"
#include "spec.cginc"

// #default CloudsScale = 1 1 0 0
// #default CloudsDrift = 1 1 0 0

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelToWorldMatrix,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4 Ambient,
        uniform float4 FrameTime,
        uniform float4 VectorParam1_CloudsScale,
        uniform float4 VectorParam2_CloudsDrift,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS]
        )
{
    int i;
    // lighting

    vout.position = mul(ModelViewProjMatrix, vin.position);
    float4 color=vertexDiffuse(vin.position.xyz,vin.normal.xyz,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    vout.diffuse=color;
    vout.uv0 = vin.uv0;
    vout.uv1 = vin.uv1;
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
    
    float4 pos=mul(ModelToWorldMatrix,vin.position);
    vout.cloudsUV = pos.xz*0.01*VectorParam1_CloudsScale.xy+frac(VectorParam2_CloudsDrift.xy*FrameTime);
}

// #default Texture3_Clouds = sfx\Explosion_01.tga
// #default CloudsColor = 1 1 1 1 

half4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform sampler2D Texture3_Clouds,
            uniform half4 VectorParam4_CloudsColor
            ) : COLOR
{
    half4 src=half4(tex2D(Texture0,In.uv0));
    half4 clouds=half4(tex2D(Texture3_Clouds,In.cloudsUV));
    clouds*=VectorParam4_CloudsColor;
    src.xyz=lerp(src.xyz,clouds.xyz,clouds.w);
    
    half3 lightmap=half3(tex2D(Texture1,In.uv1).xyz);
    
    half4 diffuse=half4(saturate(lightmap+In.diffuse.xyz),1);
    src=src*diffuse;
    return src;
}
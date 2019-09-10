// #class Object,Terrain
// #Lightmap

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float2 uv0          : TEXCOORD0;
    float2 lmUV         : TEXCOORD1;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
    float fog          : FOG;
    float2 uv0          : TEXCOORD0;
    float2 lmUV         : TEXCOORD1;
};

#ifdef VS_VER_MAJOR
#if VS_VER_MAJOR < 2
	#define MAX_LIGHTS  2
#else
	#define MAX_LIGHTS  4
#endif

#else
	#define MAX_LIGHTS  4
#endif

#include "lighting.cginc"
#include "lighting2.cginc"

// #invertalpha
// #default ReflectionDrift = 0 0 0 0

void vertex1_1(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 Ambient,
        uniform float4 FogParams,
        uniform float4 VectorParam0_ReflectionDrift,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS]
        )
{
    float4 pos=vin.position;

    // lighting
    float4 color=vertexDiffuse(vin.position.xyz,vin.normal.xyz,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    vout.diffuse = float4(color.xyz,1);
   
    vout.position = mul(ModelViewProjMatrix, pos);
    vout.uv0 = vin.uv0;
    vout.lmUV = vin.lmUV;
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams).x;
}

// #default BlendingFactor = 1

#define BW float4(0.239,0.686,0.075,0)

float4 main1_1(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform float FloatParam1_BlendingFactor,
            uniform float Blend
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv0);
    src=src*saturate(In.diffuse+tex2D(Texture1,In.lmUV));
    return src;
}
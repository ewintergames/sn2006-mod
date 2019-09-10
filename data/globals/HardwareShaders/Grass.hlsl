// #class Object
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
    float  fog          : FOG;
    float2 uv0          : TEXCOORD0;
    float2 lmUV         : TEXCOORD1;
};

#define MAX_LIGHTS    2

#include "lighting.cginc"
#include "lighting2.cginc"

// #default X_amplitude = 0.2
// #default X_speed = 0.5
// #default Z_amplitude = 0.6
// #default Z_speed = 0.8

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 Ambient, uniform float FrameTime,
        uniform float FloatParam0_X_amplitude,
        uniform float FloatParam1_X_speed,
        uniform float FloatParam2_Z_amplitude,
        uniform float FloatParam3_Z_speed,
        uniform float4 FogParams,
        uniform float4 EyeInObjectSpace,
        uniform float4 LightLocalPositionTable[MAX_LIGHTS],
        uniform float4 LightColorTable[MAX_LIGHTS],
        uniform float4 LightAttenuationTable[MAX_LIGHTS]
        )
{
    float4 pos=vin.position;
    float strength=vin.uv0.y;
    float4 move=float4(sin(FrameTime*FloatParam1_X_speed)*FloatParam0_X_amplitude,
                0, sin(FrameTime*FloatParam3_Z_speed+3.14*vin.uv0.x)*FloatParam2_Z_amplitude, 0);
    pos+=move*strength;

    // lighting
    float4 color=vertexDiffuse(pos,vin.normal.xyz,Ambient,LightLocalPositionTable,LightColorTable,LightAttenuationTable);
    vout.diffuse = float4(color.xyz,1);

    vout.position = mul(ModelViewProjMatrix, pos);
    vout.uv0 = vin.uv0;
    vout.lmUV = vin.lmUV;
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture1
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv0);
    src=src*(In.diffuse+tex2D(Texture1,In.lmUV));
    return src;
}

// #class Object
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
	float	fog			: FOG;
    float2 uv0          : TEXCOORD0;
    float2 uv1          : TEXCOORD1;
    float2 caustic1UV   : TEXCOORD2;
    float2 caustic2UV   : TEXCOORD3;
};

#define MAX_LIGHTS    2

#include "lighting.cginc"
#include "lighting2.cginc"

#include "spec.cginc"

// #default Caustic1Scale = 1 1 0 0
// #default Caustic1Drift = 1 0.1 0 0
// #default Caustic2Scale = 1 1 0 0
// #default Caustic2Drift = 0.1 1 0 0
// #default Caustic2Rotation = 30

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelToWorldMatrix,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float4 Ambient,
        uniform float4 FrameTime,
        uniform float4 VectorParam1_Caustic1Scale,
        uniform float4 VectorParam2_Caustic1Drift,
        uniform float4 VectorParam3_Caustic2Scale,
        uniform float4 VectorParam4_Caustic2Drift,
        uniform float4 RotationParam7_Caustic2Rotation,
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
    vout.caustic1UV = pos.xz*0.01*VectorParam1_Caustic1Scale.xy+frac(VectorParam2_Caustic1Drift.xy*FrameTime);
    
    float2 uv2Pos=float2(dot(pos.xz,RotationParam7_Caustic2Rotation.yz),dot(pos.xz,RotationParam7_Caustic2Rotation.xy));
    vout.caustic2UV = uv2Pos*0.01*VectorParam3_Caustic2Scale.xy+frac(VectorParam4_Caustic2Drift.xy*FrameTime);
}

// #default Texture3_Caustic1 = sfx\Explosion_01.tga
// #default Texture4_Caustic2 = sfx\Explosion_01.tga
// #default Caustic1Color = 1 1 1 1 
// #default Caustic2Color = 1 1 1 1 

half4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform sampler2D Texture3_Caustic1,
            uniform sampler2D Texture4_Caustic2,
            uniform half4 VectorParam5_Caustic1Color,
            uniform half4 VectorParam6_Caustic2Color
            ) : COLOR
{
    half4 src=half4(tex2D(Texture0,In.uv0));
    half3 lightmap=half3(tex2D(Texture1,In.uv1).xyz);
    
    half4 diffuse=half4(saturate(lightmap+In.diffuse.xyz),1);
    src=src*diffuse;

    half4 caustic1=half4(tex2D(Texture3_Caustic1,In.caustic1UV));
    caustic1*=VectorParam5_Caustic1Color;
    half4 caustic2=half4(tex2D(Texture4_Caustic2,In.caustic2UV));
    caustic2*=VectorParam6_Caustic2Color;
    
    src=saturate(src+caustic1+caustic2);
    return src;
}

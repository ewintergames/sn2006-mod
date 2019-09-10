// #class Object
// #NoFog

struct App2Vert
{
    float4 position     : POSITION;
    float2 uv0          : TEXCOORD0;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float2 uv0          : TEXCOORD0;
    float2 uv1          : TEXCOORD1;
    float4 color        : COLOR0;
};

#include "lighting.cginc"

// #default AdditiveColor = 1 1 1 1
// #default Map1 = 1 0 1 0
// #default Map2 = 0 1 1 0

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 FogParams,
        uniform float FrameTime,
        uniform float4 VectorParam2_Map1,
        uniform float4 VectorParam3_Map2,
        uniform float4 VectorParam7_AdditiveColor,
        uniform float2 Blend
        )
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    float2 map1=vin.uv0*VectorParam2_Map1.z+VectorParam2_Map1.xy*FrameTime;
    float2 map2=vin.uv0*VectorParam3_Map2.z+VectorParam3_Map2.xy*FrameTime;
    
    vout.uv0 = map1;
    vout.uv1 = map2;
    
    float fog=1-fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
    vout.color = float4(1,1,1, Blend.x*fog)*VectorParam7_AdditiveColor;
}

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0
            ) : COLOR
{
    float4 src1=tex2D(Texture0,In.uv0);
    float4 src2=tex2D(Texture0,In.uv1);
    
    float4 src=saturate(src1+src2);
    
    src=src1*src2*2;
    
    src=src*In.color;
    return src;
    return src;
}

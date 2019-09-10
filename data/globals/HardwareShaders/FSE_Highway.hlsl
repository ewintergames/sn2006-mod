// #class FSE

#include "Refraction.cginc"

struct GenericIN
{
    float4 position : POSITION;
    float2 glowUV 	: TEXCOORD0;
    float2 mainUV 	: TEXCOORD1;
    float2 screenUV	: TEXCOORD2;
};

struct Vert2Frag
{
    float4 position : POSITION;
    float2 glowUV 	: TEXCOORD0;
    float2 mainUV 	: TEXCOORD1;
    float2 screenUV	: TEXCOORD2;
};

void vertex(in GenericIN vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix)
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.mainUV = vin.mainUV;
    vout.screenUV = vin.screenUV;
    vout.glowUV = vin.glowUV;
}

half4 main(in Vert2Frag In, uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform half4 ConstantColor) : COLOR
{
    half3 screen=SimpleRefraction(Texture1,In.mainUV);

    half3 glow=half3(tex2D(Texture0,In.glowUV).xyz);
    half3 picture=screen.xyz+glow*ConstantColor.xyz;
    return half4(picture,1);
}


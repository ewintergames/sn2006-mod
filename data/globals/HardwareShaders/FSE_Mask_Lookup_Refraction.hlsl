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
    float2 tileUV   : TEXCOORD3;
};

// #default Tiling_factor = 8 8 0 0

void vertex(in GenericIN vin, out Vert2Frag vout,
        uniform float4 Viewport,
        uniform float4 VectorParam4_Tiling_factor,
        uniform float4x4 ModelViewProjMatrix)
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.glowUV = vin.glowUV;
    vout.mainUV = vin.mainUV;
    vout.screenUV = vin.screenUV;
    vout.tileUV = vin.screenUV * Viewport.zw/VectorParam4_Tiling_factor.xy;
}


// #default Texture2_Full_screen_mask = ui\TV_Border_01.tga
// #default FS_mask_color = 1 1 1 1
// #default Texture4_Color_lookup = ui\Sepia_NoCompressionClampNoFilterNoMipMaps.tga
// #default Lookup_intensity = 1 0 0 0

#define BW half3(0.239,0.686,0.075)


half4 main(in Vert2Frag In, uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform half4 ConstantColor,
            uniform sampler2D Texture2_Full_screen_mask, uniform half4 VectorParam1_FS_mask_color,
            uniform sampler2D Texture4_Color_lookup,
            uniform half4 VectorParam3_Lookup_intensity) : COLOR
{
    half3 screen=SimpleRefraction(Texture1,In.mainUV);
    half3 glow=half3(tex2D(Texture0,In.glowUV).xyz);
    half3 picture=screen+glow*ConstantColor.xyz;

    half4 fsMask=half4(tex2D(Texture2_Full_screen_mask,In.screenUV))*VectorParam1_FS_mask_color;
    half3 result=lerp(picture, fsMask.xyz, fsMask.w);

    half intensity=dot(result,BW);
    half3 lookup=half3(tex2D(Texture4_Color_lookup,half2(intensity,0.5)).xyz);
    return half4(lookup*VectorParam3_Lookup_intensity.x+result*VectorParam3_Lookup_intensity.y,1);
}


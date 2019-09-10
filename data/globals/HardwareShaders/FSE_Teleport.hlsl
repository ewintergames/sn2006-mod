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
    float4 maskColor: COLOR0;
};

// #default Tiling_factor = 8 8 0 0
// #default DistortionFactor = 1

void vertex(in GenericIN vin, out Vert2Frag vout,
        uniform float4 Viewport, uniform float FloatParam1_DistortionFactor,
        uniform float4 VectorParam4_Tiling_factor,
        uniform float4x4 ModelViewProjMatrix)
{
    float dist=length(vin.position.xy+float2(0,-0.27));
    float2 af=abs(vin.position.xy);
    float mf=max(af.x,af.y);
    
    if(mf>=1.0)
    {
        vout.position = mul(ModelViewProjMatrix, vin.position);
    }
    else
    {
        float distFactor=max(0,2-dist)/2;
        distFactor=distFactor*distFactor;
        distFactor=distFactor*distFactor;
    
        float2 circlePos=vin.position.xy*(1+dist*FloatParam1_DistortionFactor);
        float2 pos=lerp(vin.position.xy,circlePos,distFactor);
    
        vout.position = mul(ModelViewProjMatrix, float4(pos,vin.position.zw));
    }
    
    vout.glowUV = vin.glowUV;
    vout.mainUV = vin.mainUV;
    vout.screenUV = vin.screenUV;
    vout.tileUV = vin.screenUV * Viewport.zw/VectorParam4_Tiling_factor.xy;
    vout.maskColor = float4(1,1,1,saturate(1.5-0.5*abs(FloatParam1_DistortionFactor)));
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

    half4 fsMask=half4(tex2D(Texture2_Full_screen_mask,In.screenUV))*VectorParam1_FS_mask_color*In.maskColor;
    half3 result=lerp(picture, fsMask.xyz, fsMask.w);

    half intensity=dot(result,BW);
    half3 lookup=half3(tex2D(Texture4_Color_lookup,half2(intensity,0.5)).xyz);
    return half4(lookup*VectorParam3_Lookup_intensity.x+result*VectorParam3_Lookup_intensity.y,1);
}


// #class FSE

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
// #default Texture3_Tiled_mask = ui\TV_Lines_01_NoCompressionNoFilter.tga
// #default Tiled_mask_color = 1 1 1 1


half4 main(in Vert2Frag In, uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform half4 ConstantColor,
            uniform sampler2D Texture2_Full_screen_mask, uniform half4 VectorParam1_FS_mask_color,
            uniform sampler2D Texture3_Tiled_mask, uniform half4 VectorParam2_Tiled_mask_color, uniform half4 FloatParam1_RefractionPower) : COLOR
{
    half4 screen4=half4(tex2D(Texture1,In.mainUV));
    half2 uvDisp=(screen4.w*FloatParam1_RefractionPower).xx;
    
    half3 screen=half3(tex2D(Texture1,In.mainUV+uvDisp).xyz);
    half3 glow=half3(tex2D(Texture0,In.glowUV).xyz);
    half3 picture=screen+glow*ConstantColor.xyz;

    half4 fsMask=half4(tex2D(Texture2_Full_screen_mask,In.screenUV))*VectorParam1_FS_mask_color;
    half3 result1=lerp(picture, fsMask.xyz, fsMask.w);
    half4 tiledMask=half4(tex2D(Texture3_Tiled_mask,In.tileUV))*VectorParam2_Tiled_mask_color;
    half3 result2=lerp(result1, tiledMask.xyz, tiledMask.w);
    
    return half4(result2,1);
}


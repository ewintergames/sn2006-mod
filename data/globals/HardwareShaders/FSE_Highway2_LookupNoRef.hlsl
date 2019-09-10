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
    float2 mask1UV  : TEXCOORD3;
    float2 mask2UV  : TEXCOORD4;
};

void vertex(in GenericIN vin, out Vert2Frag vout,
        uniform float FloatParam0_SpeedFactor,
        uniform float4x4 ModelViewProjMatrix)
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.mainUV = vin.mainUV;
    vout.screenUV = vin.screenUV;
    vout.glowUV = vin.glowUV;
    
    float2 speedDir=-normalize(vin.screenUV-0.5.xx)*FloatParam0_SpeedFactor;
    speedDir.y*=-1;
    vout.mask1UV=vout.mainUV+speedDir;
    vout.mask2UV=vout.mainUV+speedDir*2;
}

// #default Texture2_SpeedMask = sfx\FSE_Speed_Alpha_01.tga
// #default Texture4_Color_lookup = ui\Sepia_NoCompressionClamp.tga
// #default SpeedFactor = 0.01
// #default AlphaFactor = 0.5 0.5 0 0
// #default Lookup_intensity = 1 0 0 0

#define BW float4(0.239,0.686,0.075,0)

half4 main(in Vert2Frag In, uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform sampler2D Texture2_SpeedMask, 
            uniform half4 VectorParam1_AlphaFactor,
            uniform half4 ConstantColor,
            uniform sampler2D Texture4_Color_lookup, uniform half4 VectorParam3_Lookup_intensity) : COLOR
{
    half3 screen=tex2D(Texture1,In.mainUV);
    half speedMask=tex2D(Texture2_SpeedMask,In.screenUV).w;
    half3 speedScreen1=tex2D(Texture1,In.mask1UV).xyz;
    half3 speedScreen2=tex2D(Texture1,In.mask2UV).xyz;
   
    half2 mask=VectorParam1_AlphaFactor.xy*speedMask.xx;
    
    half3 picture=lerp(screen, speedScreen1, mask.x);
    picture=lerp(picture, speedScreen2, mask.y);
    
    half3 glow=half3(tex2D(Texture0,In.glowUV).xyz);
    picture=picture+glow*ConstantColor.xyz;
    
    half intensity=dot(picture,BW);
    half3 lookup=half3(tex2D(Texture4_Color_lookup,half2(intensity,0.5)).xyz);
    return half4(lookup*VectorParam3_Lookup_intensity.x+picture*VectorParam3_Lookup_intensity.y,1);
}

//------------------------------------------------
// shaders below 2.0

struct Vert2Frag1_1
{
    float4 position : POSITION;
    float2 glowUV 	: TEXCOORD0;
    float2 mainUV 	: TEXCOORD1;
    float2 screenUV	: TEXCOORD2;
    
};

void vertex1_1(in GenericIN vin, out Vert2Frag1_1 vout,
        uniform float FloatParam0_SpeedFactor,
        uniform float4x4 ModelViewProjMatrix)
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.mainUV = vin.mainUV;
    vout.screenUV = vin.screenUV;
    vout.glowUV = vin.glowUV;
}

half4 main1_4(in Vert2Frag1_1 In, uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform half4 ConstantColor,
            uniform sampler2D Texture4_Color_lookup, uniform half4 VectorParam3_Lookup_intensity) : COLOR
{
    half3 picture=tex2D(Texture1,In.mainUV).xyz;
    half3 glow=half3(tex2D(Texture0,In.glowUV).xyz);
    picture=picture+glow*ConstantColor.xyz;
    
    half intensity=dot(picture,BW);
    half3 lookup=half3(tex2D(Texture4_Color_lookup,half2(intensity,0.5)).xyz);
    return half4(lookup*VectorParam3_Lookup_intensity.x+picture*VectorParam3_Lookup_intensity.y,1);
}

// in ps1.1 we haven't dependent texture read, and only tex0..3, so good bye Texture4_Color_lookup
half4 main1_1(in Vert2Frag1_1 In, uniform sampler2D Texture0, uniform sampler2D Texture1, uniform half4 ConstantColor) : COLOR
{
    half3 picture=tex2D(Texture1,In.mainUV).xyz;
    half3 glow=half3(tex2D(Texture0,In.glowUV).xyz);
    picture=picture+glow*ConstantColor.xyz;
    return half4(picture,1);
}




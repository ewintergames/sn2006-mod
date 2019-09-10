// #class FSE
// #NoFog

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
        uniform float FloatParam0_SpeedFactor,
        uniform float4x4 ModelViewProjMatrix)
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.mainUV = vin.mainUV;
    vout.screenUV = vin.screenUV;
    vout.glowUV = vin.glowUV;

}

// #default Texture4_Color_lookup = ui\Sepia_NoCompressionClamp.tga
// #default Lookup_intensity = 1 0 0 0
// #default GlowFactor = 0.5 0.5 0 0
// #default Out_focus_glow_scale = 1
// #default In_focus_glow_steal = 0

#define BW float4(0.239,0.686,0.075,0)

half4 main(in Vert2Frag In, uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform half4 VectorParam2_GlowFactor,
            uniform half4 ConstantColor,
            uniform sampler2D Texture4_Color_lookup, uniform half4 VectorParam3_Lookup_intensity,
			uniform float FloatParam1_Out_focus_glow_scale,
			uniform float FloatParam2_In_focus_glow_steal) : COLOR
{
    half4 screen=tex2D(Texture1,In.mainUV);
    half3 picture=screen.xyz;    
    half3 glow=half3(tex2D(Texture0,In.glowUV).xyz)*ConstantColor.xyz;
	
	float picScale = 1.0 - FloatParam1_Out_focus_glow_scale *(1-screen.w);
	float glowScale = 1.0 - FloatParam2_In_focus_glow_steal*screen.w;
	
	float picFactor = VectorParam2_GlowFactor.x * picScale;
	float glowFactor =VectorParam2_GlowFactor.x * (1-picScale) + VectorParam2_GlowFactor.y * glowScale;
	
	picture=picture*picFactor +glow*glowFactor;
	
    half intensity=dot(picture,BW);
    half3 lookup=half3(tex2D(Texture4_Color_lookup,half2(intensity,0.5)).xyz);
    return half4(lookup*VectorParam3_Lookup_intensity.x+picture*VectorParam3_Lookup_intensity.y,1);
}

struct Vert2Frag1_1
{
    float4 position : POSITION;
    float2 glowUV 	: TEXCOORD0;
    float2 mainUV 	: TEXCOORD1;
    float2 screenUV	: TEXCOORD2;
};

void vertex1_1(in GenericIN vin, out Vert2Frag1_1 vout,
        uniform float4x4 ModelViewProjMatrix)
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.mainUV = vin.mainUV;
    vout.screenUV = vin.screenUV;
    vout.glowUV = vin.glowUV;
}

/*
	can't fit this lookup into 1.4 instructions limit

half4 main_UNDONE_1_4(in Vert2Frag In, uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform half4 VectorParam2_GlowFactor,
            uniform half4 ConstantColor,
            uniform sampler2D Texture4_Color_lookup, uniform half4 VectorParam3_Lookup_intensity
			) : COLOR
{
	half3 glow=half3(tex2D(Texture0,In.glowUV).xyz)*ConstantColor.xyz;
	half4 screen=tex2D(Texture1,In.mainUV);
	
	float picScale = 0.2 + screen.w;
	float glowScale = 1 - 0.7*screen.w;
	float glowDelta = glowScale - picScale*0.35;
	half3 picture=screen.xyz*picScale +0.75*glow + glow*glowDelta;
	
    half intensity=dot(screen.xyz,BW);
    half3 lookup=half3(tex2D(Texture4_Color_lookup,half2(intensity,0.5)).xyz);
    return half4(lookup*VectorParam3_Lookup_intensity.x+picture*VectorParam3_Lookup_intensity.y,1);
}

*/

half4 main1_1(in Vert2Frag1_1 In, uniform sampler2D Texture0, uniform sampler2D Texture1,uniform half4 ConstantColor
			) : COLOR
{
	half3 glow=half3(tex2D(Texture0,In.glowUV).xyz)*ConstantColor.xyz;
	half4 screen=tex2D(Texture1,In.mainUV);
	
	float picScale = 0.2 + screen.w;
	float glowScale = 1 - 0.7*screen.w;
	float glowDelta = glowScale - picScale*0.35;
	half3 picture=screen.xyz*picScale +0.75*glow + glow*glowDelta;
	
	return half4(picture.xyz, 1);
}

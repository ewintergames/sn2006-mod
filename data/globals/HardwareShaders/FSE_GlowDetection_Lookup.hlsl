// #class FSEGlowDetection

#define BW half3(0.239,0.686,0.075)

struct GenericIn
{
    half2 uv1 : TEXCOORD0;
};

// #default Texture1_intensity_lookup = FSE\Gradient_Line_02_BW_NoCompressionClamp.tga
// #default LookupMultiplier = 1 1 1 1
// #default BeforeLookupMultiplier = 1

half4 main(in GenericIn In, uniform sampler2D Texture0,
            uniform sampler2D Texture1_intensity_lookup, uniform half4 VectorParam1_LookupMultiplier,
            uniform half FloatParam1_BeforeLookupMultiplier
        ) : COLOR
{
    half3 color=tex2D(Texture0,In.uv1).xyz;
    half intensity=saturate(dot(color,BW)*FloatParam1_BeforeLookupMultiplier);
    half3 lookup=half3(tex2D(Texture1_intensity_lookup,half2(intensity,0.5)).xyz);
    return half4(color*lookup*VectorParam1_LookupMultiplier.xyz,1);
}

half4 main1_4(in GenericIn In, uniform sampler2D Texture0,
            uniform sampler2D Texture1_intensity_lookup, uniform half4 VectorParam1_LookupMultiplier,
            uniform half FloatParam1_BeforeLookupMultiplier
        ) : COLOR
{
    half3 color=tex2D(Texture0,In.uv1).xyz;
    half intensity=saturate(dot(color,BW)*FloatParam1_BeforeLookupMultiplier);
    half3 lookup=half3(tex2D(Texture1_intensity_lookup,half2(intensity,0.5)).xyz);
    return half4(color*lookup*VectorParam1_LookupMultiplier.xyz,1);
}



half4 main1_1(in GenericIn In, uniform sampler2D Texture0,
            uniform sampler2D Texture1_intensity_lookup, uniform half4 VectorParam1_LookupMultiplier,
            uniform half FloatParam1_BeforeLookupMultiplier,
			uniform half4 VectorParam2_LookupColor0,
			uniform half4 VectorParam3_LookupColor1
        ) : COLOR
{
    half3 color=tex2D(Texture0,In.uv1).xyz;
    half intensity=saturate(dot(color,BW)*FloatParam1_BeforeLookupMultiplier);
	half3 lookup = half3(1,1,1);
    return half4(color*lookup*VectorParam1_LookupMultiplier.xyz,1);
}

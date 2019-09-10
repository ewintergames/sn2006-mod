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
};

void vertex(in GenericIN vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix)
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.glowUV = vin.glowUV;
    vout.mainUV = vin.mainUV;
    vout.screenUV = vin.screenUV;
}


// #default Texture4_Color_lookup = ui\Sepia_NoCompressionClamp.tga
// #default Lookup_intensity = 1 0 0 0

#define BW float4(0.239,0.686,0.075,0)

half4 main(in Vert2Frag In, uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform half4 ConstantColor,
            uniform sampler2D Texture4_Color_lookup, uniform half4 VectorParam3_Lookup_intensity) : COLOR
{
    half3 screen=half3(tex2D(Texture1,In.mainUV).xyz);
    half3 glow=half3(tex2D(Texture0,In.glowUV).xyz);
    half3 picture=screen+glow*ConstantColor.xyz;

    half intensity=dot(picture,BW);
    half3 lookup=half3(tex2D(Texture4_Color_lookup,half2(intensity,0.5)).xyz);
    return half4(lookup*VectorParam3_Lookup_intensity.x+picture*VectorParam3_Lookup_intensity.y,1);
}


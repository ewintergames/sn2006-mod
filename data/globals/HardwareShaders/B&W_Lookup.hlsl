
#define BW float4(0.239,0.686,0.075,0)

struct GenericIn
{
    float2 uv1 : TEXCOORD0;
    float4 diffColor : COLOR0;
};

// #default Multiplicator = 2.5
// #default Texture1_Lookup = test\Gradient_Line_01.tga

float4 main(in GenericIn In, 
            uniform sampler2D Texture0, uniform sampler2D Texture1_Lookup,
            uniform float FloatParam0_Multiplicator
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv1)*In.diffColor;
    float intensity=dot(src,BW)*FloatParam0_Multiplicator;
    float4 lookup=tex2D(Texture1_Lookup,float2(intensity,0.5));
    return float4(lookup.xyz,src.w);
}


#define BW float4(0.239,0.686,0.075,0)

struct GenericIn
{
    float2 uv1 : TEXCOORD0;
    float4 diffColor : COLOR0;
};

float4 main(in GenericIn In, uniform sampler2D Texture0) : COLOR
{
    float4 src=tex2D(Texture0,In.uv1)*In.diffColor;
    float intensity=dot(src,BW);
    return float4(intensity,intensity,intensity,src.w);
}


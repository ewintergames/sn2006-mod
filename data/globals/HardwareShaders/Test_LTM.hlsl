// #class Object

struct App2Vert
{
    float3 position     : POSITION;
    float3 normal       : NORMAL;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float3 normal       : TEXCOORD0;
};

void vertex(in App2Vert vin, out Vert2Frag vout, uniform float4x4 ModelViewProjMatrix)
{
    vout.position = mul(ModelViewProjMatrix, float4(vin.position.xyz,1));
    vout.normal=vin.normal;
}

float4 main(in Vert2Frag In, uniform samplerCUBE Texture2_CubeMap) : COLOR
{
    float4 cube=texCUBE(Texture2_CubeMap,In.normal);
    return float4(cube.xyz,1);
}


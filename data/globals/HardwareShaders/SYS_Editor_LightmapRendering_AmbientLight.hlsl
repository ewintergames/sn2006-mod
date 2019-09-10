// #class SYS
// #hidden
// #NoFog

struct App2Vert
{
    float4 position     : POSITION;
};

struct Vert2Frag
{
    float4 position         : POSITION;
};

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix
        )
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
}

float4 main(in Vert2Frag In, uniform float4 VectorParams[8]) : COLOR
{
    float4 lightColor=VectorParams[2];
    return float4(lightColor.xyz,1);
}



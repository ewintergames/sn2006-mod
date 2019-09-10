// #class SYS
// #hidden
// #NoFog

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float2 uv1          : TEXCOORD1;
};

struct Vert2Frag
{
    float4 position         : POSITION;
    float3 worldPosition    : TEXCOORD0;
    float3 worldNormal      : TEXCOORD1;
};

struct FragOut
{
    float4 position        : COLOR0;
    float4 normal          : COLOR1;
};

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 VectorParams[8]
        )
{
    float3 pos=float3(vin.uv1,0);
    
    float4x4 objectRenderMatrix;
    objectRenderMatrix[0]=VectorParams[4];
    objectRenderMatrix[1]=VectorParams[5];
    objectRenderMatrix[2]=VectorParams[6];
    objectRenderMatrix[3]=VectorParams[7];
    
    vout.position = mul(ModelViewProjMatrix, float4(pos,1));
    vout.worldPosition = mul(objectRenderMatrix, vin.position).xyz;
    vout.worldNormal = mul((float3x3)objectRenderMatrix,vin.normal);
}

void main(in Vert2Frag In, out FragOut Out)
{
    Out.position = float4(In.worldPosition,1);
    Out.normal = float4(normalize(In.worldNormal),0);
}



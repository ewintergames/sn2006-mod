// #class SYS
// #hidden
// #NoFog

struct App2Vert
{
    float4 position     : POSITION;
    float2 uv           : TEXCOORD0;
};

struct Vert2Frag
{
    float4 position         : POSITION;
    float2 uv               : TEXCOORD0;
};

#include "SysLMGen.HLSLinc"

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix
        )
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.uv = vin.uv;
}

float4 main(in Vert2Frag In, uniform float4 VectorParams[8],
            uniform sampler2D Texture1, uniform sampler2D Texture2, uniform samplerCUBE Texture3) : COLOR
{
    float4 positionFull=tex2D(Texture1,In.uv);
    if(positionFull.w>0)
    {
        float3 position=positionFull.xyz;
        float3 normal=normalize(tex2D(Texture2,In.uv).xyz);
        
        float3 lightGlobalPosition=VectorParams[0].xyz;
        float4 lightFalloff=VectorParams[1];
        float4 lightColor=VectorParams[2];
    
        float dist=length(position-lightGlobalPosition);
        float distFactor=1-saturate((dist-lightFalloff.x)/(lightFalloff.y-lightFalloff.x));
        
        float3 toLightVector=normalize(lightGlobalPosition-position);
        float dotFactor=dot(normal,toLightVector);
        float diffFactor=saturate(dotFactor);
        
        return float4(lightColor.xyz*distFactor*diffFactor,1);
    }
    else
        return float4(0,0,0,0);
}

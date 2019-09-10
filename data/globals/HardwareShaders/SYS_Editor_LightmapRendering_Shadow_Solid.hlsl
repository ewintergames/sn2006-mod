// #class SYS
// #hidden
// #NoFog

struct App2Vert
{
    float3 vertex1      : POSITION;
    float3 vertex2      : NORMAL;
    float2 screenPos    : TEXCOORD0;
    float3 vertex3      : TANGENT;
};

struct Vert2Frag
{
    float4 position         : POSITION;
    float2 uv               : TEXCOORD0;
    float3 v0               : TEXCOORD1;
    float3 edge1            : TEXCOORD2;
    float3 edge2            : TEXCOORD3;
};

#include "SysLMGen.HLSLinc"

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix, uniform float4 VectorParams[4], uniform float FloatParams[4]
        )
{
    bool ok=true;

    // cull the triangles facing away from light source
    float4 lightPos=float4(VectorParams[1].xyz,1);
    float3 edge1=vin.vertex2-vin.vertex1;
    float3 edge2=vin.vertex3-vin.vertex1;
    float3 normal=cross(edge1,edge2);
    float4 plane=float4(normal,-dot(normal,vin.vertex1));
    
    float pf=dot(plane,lightPos);
    if(pf<=0) ok=false;
    else
    {
        // reject triangles outside light range
        float ldist1=length(vin.vertex1-lightPos.xyz);
        float ldist2=length(vin.vertex2-lightPos.xyz);
        float ldist3=length(vin.vertex3-lightPos.xyz);
        float range=FloatParams[1];
        
        if(ldist1>range && ldist2>range && ldist3>range) ok=false;
    }

    if(ok) vout.position = mul(ModelViewProjMatrix, float4(vin.screenPos,0,1));
    else vout.position=float4(0,0,0,1);
    
    vout.uv = vin.screenPos.xy*0.5+0.5;
    vout.v0 = vin.vertex1;
    vout.edge1 = edge1;
    vout.edge2 = edge2;
}

float4 main(in Vert2Frag In, uniform float4 VectorParams[4],
        uniform sampler2D Texture0, uniform sampler2D Texture1) : COLOR
{
    float4 lightPos=VectorParams[1];
    float4 globalPosition=tex2D(Texture1,In.uv);
    clip(globalPosition.w-1);

    float3 start=lightPos.xyz;
    float3 end=globalPosition.xyz;

    float3 dir=end-start;
    
    float3 pvec=cross(dir,In.edge2);
    float det=dot(In.edge1,pvec);
    clip(abs(det)-0.0001);
    
    float3 tvec=start-In.v0;
	float u=dot(tvec,pvec)/det;
    clip(u);
    clip(1-u);
    
	float3 qvec=cross(tvec,In.edge1);
	float v=dot(dir,qvec)/det;
    clip(v);
    clip(1-u-v);
    
	float t=dot(In.edge2,qvec)/det;
    clip(t);
    clip(1-1.01*t);
    
    return float4(0,0,0,0);
}

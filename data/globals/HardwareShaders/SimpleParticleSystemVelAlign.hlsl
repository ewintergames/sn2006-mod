// #NoFog

struct GenericIN 
{
    float4 position     : POSITION;
    float4 normal       : NORMAL;
    float2 uv           : TEXCOORD0;
    float2 billboard    : TEXCOORD1;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
    float2 uv           : TEXCOORD0;
};

#include "Lighting.cginc"

void vertex1_1(in GenericIN vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix, 
        uniform float4 FrameTime, uniform float4 VectorParams[8], uniform float FloatParams[8],
        uniform float4 EyeInObjectSpace, uniform float4 FogParams,
        uniform half Blend,
        uniform float4 ScreenPlanes[3])
{
    float DeltaT = fmod(max(FrameTime.x - vin.position.w, 0.0), VectorParams[0].x);
    float4 pos=float4(vin.position.xyz+vin.normal.xyz*DeltaT,1)+VectorParams[1]*DeltaT*DeltaT*0.5;
    

	float3 velNorm = normalize(vin.normal.xyz + VectorParams[1].xyz * DeltaT);
	float3 xaxis = normalize(cross(ScreenPlanes[2].xyz, velNorm));
	float3 yaxis = normalize(cross(ScreenPlanes[2].xyz, xaxis));
	
	
    float4 tm=float4(DeltaT,DeltaT,DeltaT,DeltaT)-VectorParams[2];
    float4 ind=round(max(tm,float4(0,0,0,0))/tm);
    int node=dot(ind,float4(1,1,1,1))-1;
    float t=(DeltaT-FloatParams[node])/(FloatParams[node+1]-FloatParams[node]);

    vout.diffuse=lerp(VectorParams[3+node], VectorParams[3+node+1], t);
    float2 corner=vin.billboard-float2(0.5, 0.5);
    float4 billboard=float4(xaxis*corner.x+yaxis*corner.y, 0);
    float sz=lerp(FloatParams[4+node], FloatParams[4+node+1], t)*0.7;
    pos=pos+billboard*sz;
    
    vout.position = mul(ModelViewProjMatrix, pos);
    vout.uv = vin.uv;
    float fog = 1-fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
    vout.diffuse.w*=Blend*fog;
}

float4 main1_1(in Vert2Frag In, 
            uniform sampler2D Texture0
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv);
    src=src*In.diffuse;
    return src;
}




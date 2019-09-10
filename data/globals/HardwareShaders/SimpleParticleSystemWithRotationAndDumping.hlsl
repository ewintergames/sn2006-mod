// #NoFog

struct GenericIN 
{
    float4 position     : POSITION;
    float4 normal       : NORMAL;
    float2 uv           : TEXCOORD0;
    float2 billboard    : TEXCOORD1;
    float2 random       : TEXCOORD2;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
    float2 uv           : TEXCOORD0;
};

#include "Lighting.cginc"
#define PI  3.1415926535897932384626433832795

void vertex1_1(in GenericIN vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix, 
        uniform float4 FrameTime, uniform float4 VectorParams[9], uniform float FloatParams[8],
        uniform float4 EyeInObjectSpace, uniform float4 FogParams,
        uniform float4 ScreenPlanes[2],
		uniform half Blend)
{
    float DeltaT = fmod(max(FrameTime.x - vin.position.w, 0.0), VectorParams[0].x);
    float svf=max(0,1.0-2.0*atan(VectorParams[8].y*DeltaT)*VectorParams[8].z/PI);
    float4 pos=float4(vin.position.xyz+vin.normal.xyz*DeltaT*svf,1)+VectorParams[1]*DeltaT*DeltaT*0.5;
    
    float4 tm=float4(DeltaT,DeltaT,DeltaT,DeltaT)-VectorParams[2];
    float4 ind=round(max(tm,float4(0,0,0,0))/tm);
    int node=dot(ind,float4(1,1,1,1))-1;
    float t=(DeltaT-FloatParams[node])/(FloatParams[node+1]-FloatParams[node]);

    vout.diffuse=lerp(VectorParams[3+node], VectorParams[3+node+1], t);
    float2 corner=vin.billboard-float2(0.5, 0.5);
    
    float rot=vin.random.x*VectorParams[8].x*FrameTime;
    float ss, cs;
    
    sincos(rot*PI/180, ss, cs);    
    float4 scs=float4(ss,cs,-ss,-cs);
    corner=float2(dot(corner,scs.yx),dot(corner,scs.zy));
    
    float4 billboard=ScreenPlanes[0]*corner.x+ScreenPlanes[1]*corner.y;
    float sz=lerp(FloatParams[4+node], FloatParams[4+node+1], t)*0.7;
    pos=pos+billboard*sz;
    
    vout.position = mul(ModelViewProjMatrix, pos);
    vout.uv = vin.uv;
	
	float f = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams); 
	vout.diffuse.w*=f*Blend;
}

float4 main1_1(in Vert2Frag In, uniform sampler2D Texture0) : COLOR
{
    float4 src=tex2D(Texture0,In.uv);
    src=src*In.diffuse;
    return src;
}




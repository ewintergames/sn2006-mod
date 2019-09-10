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
        uniform float4 ScreenPlanes[2])
{
    float DeltaT = fmod(max(FrameTime.x - vin.position.w, 0.0), VectorParams[0].x);
    float4 pos=float4(vin.position.xyz+vin.normal.xyz*DeltaT,1)+VectorParams[1]*DeltaT*DeltaT*0.5;
    
    float t=DeltaT/VectorParams[0].x;
    vout.diffuse=lerp(VectorParams[3], VectorParams[4], t);
    float2 corner=vin.billboard-float2(0.5, 0.5);
    float4 billboard=ScreenPlanes[0]*corner.x+ScreenPlanes[1]*corner.y;
    float sz=lerp(FloatParams[4], FloatParams[5], t)*0.7;
    pos=pos+billboard*sz;
    vout.position = mul(ModelViewProjMatrix, pos);
    vout.uv = vin.uv;
	float f = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
    vout.diffuse.w*=f*Blend;
}

struct GenericINPS
{
    float4 position     : POSITION;
    float4 normal       : NORMAL;
};


struct Vert2FragPS
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
	float psize		   : PSIZE;
	float2 uv			: TEXCOORD0;
};

void vertexPS1_1(in GenericINPS vin, out Vert2FragPS vout,
        uniform float4x4 ModelViewMatrix, 
		uniform float4x4 ProjectionMatrix,
		uniform float4 Viewport,
        uniform float4 FrameTime, uniform float4 VectorParams[8], uniform float FloatParams[8],
        uniform float4 EyeInObjectSpace, uniform float4 FogParams,
        uniform half Blend)
{
    float DeltaT = fmod(max(FrameTime.x - vin.position.w, 0.0), VectorParams[0].x);
    float4 pos=float4(vin.position.xyz+vin.normal.xyz*DeltaT,1)+VectorParams[1]*DeltaT*DeltaT*0.5;
	float4 eyePos = mul(ModelViewMatrix, pos);
	vout.position = mul(ProjectionMatrix, eyePos);
	
    float t=DeltaT/VectorParams[0].x;
    vout.diffuse=lerp(VectorParams[3], VectorParams[4], t);
	float sz=lerp(FloatParams[4], FloatParams[5], t)*0.7; // this is current camera space size
	float4 postProjSize = mul(ProjectionMatrix, float4(sz, sz, eyePos.z,eyePos.w));
	postProjSize/=postProjSize.w;
	vout.psize = 0.5 * postProjSize.x * Viewport.z;
	vout.uv = float2(0,0);

	float f = 1-fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
    vout.diffuse.w*=f*Blend;
}

float4 main1_1(in Vert2Frag In, uniform sampler2D Texture0) : COLOR
{
    float4 src=tex2D(Texture0,In.uv);
    src=src*In.diffuse;
    return src;
}


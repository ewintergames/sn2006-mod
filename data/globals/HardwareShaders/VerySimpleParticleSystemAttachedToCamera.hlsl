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
    half4 diffuse       : COLOR0;
    float2 uv           : TEXCOORD0;
};

#include "Lighting.cginc"

void vertex1_1(in GenericIN vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix, 
        uniform float4 FrameTime, uniform float4 VectorParams[8], uniform float FloatParams[8],
        uniform float4 EyeInWorldSpace, uniform float4 FogParams,
        uniform float4 ScreenPlanes[2],
		uniform half Blend)
{
    float DeltaT = fmod(max(FrameTime.x+VectorParams[0].x-vin.position.w, 0.0), VectorParams[0].x);
    float4 pos=float4(vin.position.xyz+vin.normal.xyz*DeltaT,1)+VectorParams[1]*DeltaT*DeltaT*0.5;
    float3 clipBoxStart=VectorParams[7].xyz;
    float3 clipBox=VectorParams[0].yzw;
    
    pos=float4(clipBoxStart+fmod(pos.xyz+clipBox*10000-clipBoxStart,clipBox),1);
    
    float t=DeltaT/VectorParams[0].x;
    vout.diffuse=half4(lerp(VectorParams[3], VectorParams[4], t));
    float2 corner=vin.billboard-float2(0.5, 0.5);
    float4 billboard=ScreenPlanes[0]*corner.x+ScreenPlanes[1]*corner.y;
    float sz=lerp(FloatParams[4], FloatParams[5], t)*0.7;
    pos=pos+billboard*sz;
    vout.position = mul(ModelViewProjMatrix, pos);
    vout.uv = vin.uv;
	float f = 1 - fogFactor(pos,EyeInWorldSpace.xyz,FogParams);
    vout.diffuse.w *= f * Blend;
}

half4 main1_1(in Vert2Frag In, uniform sampler2D Texture0) : COLOR
{
    half4 src=half4(tex2D(Texture0,In.uv));
    src=src*In.diffuse;
    return src;
}



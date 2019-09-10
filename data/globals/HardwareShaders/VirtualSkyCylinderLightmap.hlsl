// #Lightmap

struct App2Vert
{
    float4 position     : POSITION;
    float3 normal       : NORMAL;
    float2 uv0          : TEXCOORD0;
    float2 lmUV         : TEXCOORD1;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
    float fog          : FOG;
    float2 uv0          : TEXCOORD0;
    float2 lmUV         : TEXCOORD1;
    float2 reflUV       : TEXCOORD2;
};

#include "lighting.cginc"

#define MAX_LIGHTS    4
#define PI  3.1415926535897932384626433832795

// #default ReflectionDrift = 0 0 0 0
// #default TextureTiling = 1 1 0 0
// #default TextureOffset = 0 0 0 0

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 Ambient,
        uniform float4 FogParams,
        uniform float4 VectorParam0_ReflectionDrift,
        uniform float4 VectorParam1_TextureTiling,
        uniform float4 VectorParam2_TextureOffset,
        uniform AppLightIn Lights[MAX_LIGHTS]
        )
{
    float4 pos=vin.position;

    // lighting
    float4 color=Ambient;
    for(float i=0;i<MAX_LIGHTS;++i)
        color+=diffuse(Lights[i],vin.position.xyz,vin.normal);
    vout.diffuse = float4(color.xyz,1);
   
    pos = mul(ModelViewProjMatrix, pos);
    vout.position=pos;
    vout.uv0 = vin.uv0;
    vout.lmUV = vin.lmUV;
    float3 refl = vin.position.xyz-EyeInObjectSpace.xyz;
    refl=normalize(float3(dot(refl.xz,VectorParam0_ReflectionDrift.yz),refl.y,dot(refl.xz,VectorParam0_ReflectionDrift.xy)));
    
    float alpha=0.5+asin(refl.y)/PI;
    float beta=0.5*(1+atan2(refl.z,refl.x)/PI);

    vout.reflUV=VectorParam2_TextureOffset.xy+VectorParam1_TextureTiling.xy*float2(beta,alpha);
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}

// #default ReflectionIntenstiy = 1
// #default BlendingFactor = 1
// #default Texture2_EnvMap = Skies\Niebo_Cylider_01.tga

#define BW float4(0.239,0.686,0.075,0)

float4 main(in Vert2Frag In, 
            uniform sampler2D Texture0, uniform sampler2D Texture1,
            uniform sampler2D Texture2_EnvMap,
            uniform float FloatParam0_ReflectionIntenstiy,
            uniform float FloatParam1_BlendingFactor
            ) : COLOR
{
    float4 src=tex2D(Texture0,In.uv0);
    float4 reflection=float4((tex2D(Texture2_EnvMap,In.reflUV)*FloatParam0_ReflectionIntenstiy*src.w).xyz,0);
    src=src*(In.diffuse+tex2D(Texture1,In.lmUV));
    src=saturate(src+reflection);
    src=saturate(float4(src.xyz,src.w-dot(src,BW)*FloatParam1_BlendingFactor));
    return src;
}

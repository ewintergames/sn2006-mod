// #class Object
// #Lightmap

struct App2Vert
{
    float4 position     : POSITION;
    float2 uv           : TEXCOORD0;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 diffuse      : COLOR0;
    float fog          : FOG;
    float3 viewVect     : TEXCOORD0;
    float2 bump1UV      : TEXCOORD1;
    float2 bump2UV      : TEXCOORD2;
    float3 normal       : TEXCOORD3;
};

// #default Texture1_NormalMap = NormalMap\Water_01_Normal.tga
// #default Texture2_ColorLookup = Specular\Water_Specular_NoCompressionClamp.tga
// #default Texture3_EnvMap = CubeMaps\CubeMap_TET_TEST_01.tga
// #default BumpScale = 1
// #default ReflectionIntenstiy = 0.5
// #default BlendingFactor = 1
// #default WaveDirX = 1 0 1 0
// #default WaveDirY = 0 1 2 0
// #default WaveSpeed = 0.4 0.1 0.03 0
// #default WaveAmplitude = 0.125 0.2 -0.32 0
// #default Bump1 = 0.013 0 2 0
// #default Bump2 = -0.02 0.015 2.3
// #default NormalPerturbation = 0.2
// #default Bump1Rotation = 27
// #default Bump2Rotation = 0


#define PI  3.1415926535897932384626433832795

#include "lighting.cginc"
#define MAX_LIGHTS    4

#define BW float4(0.239,0.686,0.075,0)

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 EyeInObjectSpace,
        uniform float4 FrameTime,
        uniform float4 VectorParam0_WaveDirX,
        uniform float4 VectorParam1_WaveDirY,
        uniform float4 VectorParam2_WaveSpeed,
        uniform float4 VectorParam4_WaveAmplitude,
        uniform float4 VectorParam5_Bump1,
        uniform float4 VectorParam6_Bump2,
        uniform float FloatParam0_NormalPerturbation,
        uniform float4 RotationParam1_Bump1Rotation,
        uniform float4 RotationParam6_Bump2Rotation,
        uniform AppLightIn Lights[MAX_LIGHTS],
        uniform float4 FogParams,
        uniform float4 Ambient
        )
{
    float4 pos=vin.position;
    
    // Wave position (at a given time) is an input to the sinusoidal
    // function.
    float4 f4Offset = vin.uv.x*VectorParam0_WaveDirX + vin.uv.y*VectorParam1_WaveDirY + 
        VectorParam2_WaveSpeed*FrameTime;

    float4 f4FrcOffset = 2*PI*(frac(f4Offset) - 0.5f);

    float4 f4Sin, f4Cos;
    sincos(f4FrcOffset, f4Sin, f4Cos);
    
    float waveHeight = dot(f4Sin,VectorParam4_WaveAmplitude);
    pos.y+=waveHeight;

    vout.position = mul(ModelViewProjMatrix, pos);

    float4 cosWaveHeight = f4Cos*VectorParam4_WaveAmplitude;
    float3 normal = float3(-FloatParam0_NormalPerturbation*dot(cosWaveHeight,VectorParam0_WaveDirX), 1, -FloatParam0_NormalPerturbation*dot(cosWaveHeight,VectorParam1_WaveDirY));
    normal = normalize(normal);
    vout.normal = normal;
    
    float2 inUV1=float2(dot(vin.uv,RotationParam1_Bump1Rotation.yz),dot(vin.uv,RotationParam1_Bump1Rotation.xy));
    float2 inUV2=float2(dot(vin.uv,RotationParam6_Bump2Rotation.yz),dot(vin.uv,RotationParam6_Bump2Rotation.xy));
    vout.bump1UV = frac(VectorParam5_Bump1.xy*FrameTime.x)+inUV1*VectorParam5_Bump1.z;
    vout.bump2UV = frac(VectorParam6_Bump2.xy*FrameTime.x)+inUV2*VectorParam6_Bump2.z;
    
    float4 color=Ambient;
    for(float i=0;i<MAX_LIGHTS;++i)
        color+=diffuse(Lights[i],pos.xyz,normal);
        
    vout.diffuse = float4(color.xyz,dot(color.xyz,BW));
    
    vout.viewVect=normalize(EyeInObjectSpace.xyz-pos.xyz);
    vout.fog = 1 - fogFactor(vin.position.xyz,EyeInObjectSpace.xyz,FogParams);
}


float4 main(in Vert2Frag In, 
            uniform sampler2D Texture1_NormalMap,
            uniform sampler2D Texture2_ColorLookup,
            uniform samplerCUBE Texture3_EnvMap,
            uniform float FloatParam2_BumpScale,
            uniform float FloatParam4_ReflectionIntenstiy,
            uniform float FloatParam5_BlendingFactor
            ) : COLOR
{
    float4 color=tex2D(Texture2_ColorLookup,float2(In.diffuse.w,0));
    float3 bump1=UnFix(tex2D(Texture1_NormalMap,In.bump1UV).xyz);
    float3 bump2=UnFix(tex2D(Texture1_NormalMap,In.bump2UV).xyz);
    
    float3 bump=(bump1+bump2)*0.5;
    bump=normalize(bump.xzy*float3(FloatParam2_BumpScale,1,FloatParam2_BumpScale));

    float4 refl=texCUBE(Texture3_EnvMap, reflect(In.viewVect,normalize(In.normal)+bump));

    float4 ret=saturate(lerp(color, refl, FloatParam4_ReflectionIntenstiy));
    ret.w=saturate(dot(ret,BW)*FloatParam5_BlendingFactor);
    return ret;
}


// #class Billboard

struct App2Vert
{
    float4 position     : POSITION;
    float2 uv0          : TEXCOORD0;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float4 color        : COLOR0;
    float2 uv0          : TEXCOORD0;
    float2 uv1          : TEXCOORD1;
    float2 uv2          : TEXCOORD2;
    float2 uv3          : TEXCOORD3;
};

// #default Noise1 = 0.1543543  0.7         1.646432    0
// #default Noise2 = 0.42442    0.9235432   1.12432     0
// #default Noise3 = -0.844325  0.242534    1.324645    0

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix,
        uniform float4 VectorParam1_Noise1,
        uniform float4 VectorParam2_Noise2,
        uniform float4 VectorParam3_Noise3,
        uniform float FrameTime
        )
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.uv0 = vin.uv0;
    vout.uv1 = vin.uv0*VectorParam1_Noise1.z + frac(VectorParam1_Noise1.xy*FrameTime);
    vout.uv2 = vin.uv0*VectorParam2_Noise2.z + frac(VectorParam2_Noise2.xy*FrameTime);
    vout.uv3 = vin.uv0*VectorParam3_Noise3.z + frac(VectorParam3_Noise3.xy*FrameTime);
    vout.color = float4(1,1,1,1);
}

// #default Texture1_FireTexture = sfx\fire_clamp.tga
// #default Texture2_NoiseTexture = sfx\firenoise.tga
// #default NoiseCombiner = 0.3 0.3 0.2 0
// #default PerturbationScale = 0.5
// #default PerturbationFade = 0.3

half4 main(in Vert2Frag In, 
            uniform sampler2D Texture1_FireTexture,
            uniform sampler2D Texture2_NoiseTexture,
            uniform float4 VectorParam4_NoiseCombiner,
            uniform float FloatParam1_PerturbationScale,
            uniform float FloatParam2_PerturbationFade
            ) : COLOR
{
    half4 noise1=tex2D(Texture2_NoiseTexture,In.uv1);
    half4 noise2=tex2D(Texture2_NoiseTexture,In.uv2);
    half4 noise3=tex2D(Texture2_NoiseTexture,In.uv3);
    half4 noise=noise1*half4(VectorParam4_NoiseCombiner).x+noise2*half4(VectorParam4_NoiseCombiner).y+noise3*half4(VectorParam4_NoiseCombiner).z;

    half2 uv=half2(1,1)-In.uv0;
    half fade=1.0f-In.uv0.y*half(FloatParam2_PerturbationFade);
    uv+=(noise.xy-0.5f.xx)*FloatParam1_PerturbationScale*fade;
    half4 src=tex2D(Texture1_FireTexture,uv);
    src=src*half4(In.color);    
    return src;
}



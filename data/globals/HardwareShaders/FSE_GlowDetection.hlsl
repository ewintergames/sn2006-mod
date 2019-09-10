// #class FSEGlowDetection

struct AppToVert
{
    float4 position     : POSITION;
	float2 uv0          : TEXCOORD0;
	float2 uv1          : TEXCOORD1;
	float2 uv2          : TEXCOORD2;
};

struct VertToFrag
{
	half4 position : POSITION;
    float2 uv0          : TEXCOORD0;
	float2 uv1          : TEXCOORD1;
	float2 uv2          : TEXCOORD2;
};

void vertex(in AppToVert In, out VertToFrag Out)
{
    Out.position=In.position;
    Out.uv0=In.uv0;
	Out.uv1=In.uv1;
	Out.uv2=In.uv2;	
}

// #default Glow_detection_factor = 0 1 0 0

float4 main(in VertToFrag In, uniform sampler2D Texture0,
            uniform float4 VectorParam1_Glow_detection_factor
        ) : COLOR
{
    float3 color=tex2D(Texture0,In.uv0).xyz;
    float3 color2=color*color;
    float3 color3=color2*color;
    float3 res=saturate(color*VectorParam1_Glow_detection_factor.x+color2*VectorParam1_Glow_detection_factor.y+color3*VectorParam1_Glow_detection_factor.z);
    return float4(res,1);
}

//-------------------------------------
// shaders 1.x

struct VertToFrag1_1
{
	half4 position : POSITION;
    float2 uv0          : TEXCOORD0;
	float2 uv1          : TEXCOORD1;
	float2 uv2          : TEXCOORD2;
	float3 factors		: TEXCOORD3;
};


// we have to workaround ps1_x constant range limit (-1..1)

void vertex1_1(in AppToVert In, out VertToFrag1_1 Out, 
	uniform float4 VectorParam1_Glow_detection_factor)
{
    Out.position=In.position;
    Out.uv0=In.uv0;
	Out.uv1=In.uv1;
	Out.uv2=In.uv2;	
	Out.factors = VectorParam1_Glow_detection_factor.xyz * float3(0.5, 0.25, 0.125);
}


float4 main1_1(in VertToFrag1_1 In, uniform sampler2D Texture0) : COLOR
{
	float3 color =tex2D(Texture0,In.uv0).xyz;
	float3 a = color + color;
	return float4( a*(In.factors.x + a*(In.factors.y + a*In.factors.z)), 1);
}




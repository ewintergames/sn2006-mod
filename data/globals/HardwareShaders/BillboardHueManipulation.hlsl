// #class Billboard

struct App2Vert
{
    float4 position     : POSITION;
    float2 uv0          : TEXCOORD0;
    float4 color        : COLOR0;
};

struct Vert2Frag
{
    float4 position     : POSITION;
    float2 uv0          : TEXCOORD0;
    float4 r0           : TEXCOORD1;
    float4 r1           : TEXCOORD2;
    float4 r2           : TEXCOORD3;
};

#define PI  3.1415926535897932384626433832795

void GetXRotMatrix(float rs, float rc, out float4x4 m)
{
    m[0][0] = 1.0;
    m[1][0] = 0.0;
    m[2][0] = 0.0;
    m[3][0] = 0.0;
     
    m[0][1] = 0.0;
    m[1][1] = rc;
    m[2][1] = rs;
    m[3][1] = 0.0;
     
    m[0][2] = 0.0;
    m[1][2] = -rs;
    m[2][2] = rc;
    m[3][2] = 0.0;
     
    m[0][3] = 0.0;
    m[1][3] = 0.0;
    m[2][3] = 0.0;
    m[3][3] = 1.0;
}    

void GetYRotMatrix(float rs, float rc, out float4x4 m)
{
    m[0][0] = rc;
    m[1][0] = 0.0;
    m[2][0] = -rs;
    m[3][0] = 0.0;
     
    m[0][1] = 0.0;
    m[1][1] = 1.0;
    m[2][1] = 0.0;
    m[3][1] = 0.0;
     
    m[0][2] = rs;
    m[1][2] = 0.0;
    m[2][2] = rc;
    m[3][2] = 0.0;
     
    m[0][3] = 0.0;
    m[1][3] = 0.0;
    m[2][3] = 0.0;
    m[3][3] = 1.0;		
}    

void GetZShearMatrix(float dx, float dy, out float4x4 m)
{
    m[0][0] = 1.0;
    m[1][0] = 0.0;
    m[2][0] = dx;
    m[3][0] = 0.0;
     
    m[0][1] = 0.0;
    m[1][1] = 1.0;
    m[2][1] = dy;
    m[3][1] = 0.0;
     
    m[0][2] = 0.0;
    m[1][2] = 0.0;
    m[2][2] = 1.0;
    m[3][2] = 0.0;
     
    m[0][3] = 0.0;
    m[1][3] = 0.0;
    m[2][3] = 0.0;
    m[3][3] = 1.0;
}    

//-------------------------------------------------------------------------------------
void LoadZRotation(float ang, out float4x4 m)
{
	float s = sin(ang);
	float c = cos(ang);

    m[0][0] = c;
    m[1][0] = -s;
    m[2][0] = 0.0;
    m[3][0] = 0.0;
     
    m[0][1] = s;
    m[1][1] = c;
    m[2][1] = 0.0;
    m[3][1] = 0.0;
     
    m[0][2] = 0.0;
    m[1][2] = 0.0;
    m[2][2] = 1.0;
    m[3][2] = 0.0;
     
    m[0][3] = 0.0;
    m[1][3] = 0.0;
    m[2][3] = 0.0;
    m[3][3] = 1.0;
}    

//-------------------------------------------------------------------------------------
void GetHUERotationMatrix(in float rotation, out float4x4 mm)
{
    float mag = sqrt(2.0f);
    float xrs = 1.0f/mag;
    float xrc = 1.0f/mag;

    float4x4 m, tmp;
	GetXRotMatrix(xrs,xrc,m);

    mag = sqrt(3.0f);
    float yrs = -1.0f/mag;
    float yrc = sqrt(2.0f)/mag;
    
	GetYRotMatrix(yrs,yrc,tmp);
    m=mul(tmp,m);

	float3 l=mul(m,float4(0.3086,0.6094,0.0820,1)).xyz;
    float zsx = l.x/l.z;
    float zsy = l.y/l.z;
	GetZShearMatrix(zsx,zsy,tmp);
    m=mul(tmp,m);

	LoadZRotation(rotation,tmp);
    m=mul(tmp,m);
	GetZShearMatrix(-zsx,-zsy,tmp);
    m=mul(tmp,m);

	GetYRotMatrix(-yrs,yrc,tmp);
    m=mul(tmp,m);
	GetXRotMatrix(-xrs,xrc,tmp);
    m=mul(tmp,m);
    
    mm=m;
}

//-------------------------------------------------------------------------------------
void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix
        )
{
    vout.position = mul(ModelViewProjMatrix, vin.position);
    vout.uv0 = vin.uv0;
    
    float4x4 mm;
    GetHUERotationMatrix(vin.color.x*2*PI,mm);
    
    vout.r0=mm[0];
    vout.r1=mm[1];
    vout.r2=mm[2];
}

half4 main(in Vert2Frag In, 
            uniform sampler2D Texture0
            ) : COLOR
{
    half4 pic=tex2D(Texture0,In.uv0);
    
    half r=dot(half4(pic.xyz,1),In.r0);
    half g=dot(half4(pic.xyz,1),In.r1);
    half b=dot(half4(pic.xyz,1),In.r2);
    
    pic.xyz=half3(r,g,b);
    return pic;
}



// #class Terrain

struct App2Vert
{
    float4 position     : POSITION;
    float4 mask			: COLOR0;
};

struct Vert2Frag
{
    float4 position	: POSITION;
    float4 diffuse      : COLOR0;
};

void vertex(in App2Vert vin, out Vert2Frag vout,
        uniform float4x4 ModelViewProjMatrix
        )
{
	vout.position = mul(ModelViewProjMatrix, vin.position);

	float a = vin.mask.w*255;
	float c = a;

	if (a < 5)
		c = 0;
	else if (a > 250)
		c = 255;
	else
		c = 32 + (255-64)*(a - 5)/250;

	c= c/255;

	vout.diffuse=float4(c,c,c,1);
}


float4 main(in Vert2Frag In) : COLOR
{
    return In.diffuse;
}

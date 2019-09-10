


float2 Perturbation1(float2 screenUV, float Time)
{
    return screenUV+frac(float2(0.0832,-0.03)*Time);
}

float2 Perturbation2(float2 screenUV, float Time)
{
    return screenUV+frac(float2(-0.0132,0.13)*Time);
}

half3 SimpleRefraction(uniform sampler2D Screen, half2 MainUV)
{
    half4 screen4=half4(tex2D(Screen,MainUV));
    half4 screen4b=half4(tex2D(Screen,MainUV-screen4.ww*half2(0.01,0.01)));
    
    half factor=screen4b.w;
    half3 screen=screen4b.xyz*factor+screen4.xyz*(1-factor);    
    return screen;
}


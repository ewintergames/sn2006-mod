
struct AppLightIn
{
    float4 PositionInObjectSpace;
    float4 Color;
    float4 Attenuation;
};

float4 diffuse(AppLightIn light, float3 position, float3 normal)
{
    float3 dir=light.PositionInObjectSpace.xyz-position.xyz;
    float len=length(dir);
    dir/=len;
    
    float attenuation=((light.Attenuation.x+len*(light.Attenuation.y+len*light.Attenuation.z)));
    float factor=saturate(dot(normal,dir))/attenuation;
    return float4(light.Color.xyz*factor,0);
}

float4 diffuseAndSpecular(AppLightIn light, float3 position, float3 normal, out float4 specular)
{
    float3 dir=light.PositionInObjectSpace.xyz-position.xyz;
    float len=length(dir);
    dir/=len;
    
    float attenuation=max(1,((light.Attenuation.x+len*(light.Attenuation.y+len*light.Attenuation.z))));
    specular=light.Color/attenuation;
    float factor=saturate(dot(normal,dir))/attenuation;
    return float4(light.Color.xyz*factor,0);
}

float ooLightAttenuation(AppLightIn light, float3 position)
{
    float3 dir=light.PositionInObjectSpace.xyz-position.xyz;
    float len=length(dir);
    float attenuation=((light.Attenuation.x+len*(light.Attenuation.y+len*light.Attenuation.z)));
    return saturate(1/attenuation);
}

float ooLightAttenuationDirect(float3 lightPosInObjectSpace, float4 lightAtt, float3 position)
{
    float3 dir=lightPosInObjectSpace-position.xyz;
    float len=length(dir);
    float attenuation=((lightAtt.x+len*(lightAtt.y+len*lightAtt.z)));
    return saturate(1/attenuation);
}

float fogFactor(float3 position, float3 eyePosition, float4 fogRange)
{
    return saturate((length(position-eyePosition)-fogRange.x)/fogRange.z);
}

float4 fog(float4 pixelColor, float4 fogColor, float fogFactor)
{
    return float4(lerp(pixelColor.xyz, fogColor.xyz, fogFactor),pixelColor.w);
}

float4 fogAlpha(float4 pixelColor, float4 fogColor, float fogFactor)
{
    return lerp(pixelColor, fogColor, fogFactor);
}

half4 fogHalf(half4 pixelColor, half4 fogColor, half fogFactor)
{
    return half4(lerp(pixelColor.xyz, fogColor.xyz, fogFactor),pixelColor.w);
}

half3 fogHalf3(half3 pixelColor, half3 fogColor, half fogFactor)
{
    return lerp(pixelColor, fogColor, fogFactor);
}

half4 fogHalfAdditive(half4 pixelColor, half fogFactor)
{
    return half4(pixelColor.xyz*(1-fogFactor),pixelColor.w);
}

float3 Fix(float3 fVec)
{
    return (fVec/2.0f + 0.5f);
}

float3 UnFix(float3 fVec)
{
    return (fVec*2.0f - 1.0f);
}

void ModelToTangentMatrix(float3 normal, float4 tangent, out float3x3 objToTangentSpace)
{
  	float3 B = normal.yzx*tangent.zxy;
  	B=(-tangent.yzx * normal.zxy)+B;

    objToTangentSpace[0] = tangent.xyz*tangent.w;
    objToTangentSpace[1] = B;
    objToTangentSpace[2] = normal;
}

half3 HQNormalMap(uniform sampler2D textureMap, half2 uv)
{
    half4 txt=2*(tex2D(textureMap,uv)-0.5);
    half3 normal=half3(txt.wy,sqrt(1-(txt.y*txt.y+txt.w*txt.w)));
    return normal;
}

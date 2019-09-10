
float4 specularAttenuation(const AppLightIn light, float3 position)
{
    float3 dir=light.PositionInObjectSpace.xyz-position.xyz;
    float len=length(dir);
    float attenuation=((light.Attenuation.x+len*(light.Attenuation.y+len*light.Attenuation.z)));
    float factor=saturate(1.0f/attenuation);
    return light.Color*factor;
}

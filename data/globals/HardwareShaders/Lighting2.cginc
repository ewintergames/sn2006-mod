
float4 vertexDiffuseSingleLight(float3 position, float3 normal, float4 LightLocalPosition, float4 LightColor, float4 LightAttenuation)
{
    float3 dir=LightLocalPosition.xyz-position;
    float len=length(dir);
    dir/=len;
    
    float attenuation=((LightAttenuation.x+len*(LightAttenuation.y+len*LightAttenuation.z)));
    float factor=saturate(dot(normal,dir))/attenuation;
    return float4(LightColor.xyz*factor,0);
}


float4 vertexDiffuse(float3 position, float3 normal, float4 Ambient, float4 LightLocalPositionTable[MAX_LIGHTS], float4 LightColorTable[MAX_LIGHTS], float4 LightAttenuationTable[MAX_LIGHTS])
{
    float4 diffuse=Ambient;
    for(int i=0;i<MAX_LIGHTS;++i)
        diffuse+=vertexDiffuseSingleLight(position,normal,LightLocalPositionTable[i],LightColorTable[i],LightAttenuationTable[i]);
        
    return diffuse;
}

float4 vertexDiffuseAndSpecularSingleLight(float3 position, float3 normal, float4 LightLocalPosition, float4 LightColor, float4 LightAttenuation, out float4 specular)
{
    float3 dir=LightLocalPosition.xyz-position.xyz;
    float len=length(dir);
    dir/=len;
    
    float attenuation=max(1,((LightAttenuation.x+len*(LightAttenuation.y+len*LightAttenuation.z))));
    specular=float4(LightColor.xyz/attenuation,0);
    float factor=saturate(dot(normal,dir))/attenuation;
    return float4(LightColor.xyz*factor,0);
}

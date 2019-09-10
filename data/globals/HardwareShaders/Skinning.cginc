
void SkinPositionOnly(out float3 position, float4 sourcePos, float4 indices, float4 weights, float3x4 BoneMatrices[MAX_SKINNING_BONES])
{
    position=float3(0,0,0);
    
    float4 inds=round(indices*255);
    for(int i=0;i<4;++i)
    {
        position+=mul(BoneMatrices[inds.x],sourcePos).xyz*weights.x;
        
        weights=weights.yzwx;
        inds=inds.yzwx;            }
}


void Skin(out float3 position, out float3 normal, float4 sourcePos, float3 sourceNormal, float4 indices, float4 weights, float3x4 BoneMatrices[MAX_SKINNING_BONES])
{
    position=float3(0,0,0);
    normal=float3(0,0,0);
    
    float4 inds=round(indices*255);
    for(int i=0;i<4;++i)
    {
        position+=mul(BoneMatrices[inds.x],sourcePos).xyz*weights.x;
        normal+=mul((float3x3)BoneMatrices[inds.x],sourceNormal)*weights.x;
        
        weights=weights.yzwx;
        inds=inds.yzwx;            }
}

void SkinTangent(out float3 position, out float3 normal, out float4 tangent, float4 sourcePos, float3 sourceNormal, float4 sourceTangent, float4 indices, float4 weights, float3x4 BoneMatrices[MAX_SKINNING_BONES])
{
    position=float3(0,0,0);
    normal=float3(0,0,0);
    tangent=float4(0,0,0,sourceTangent.w);
    
    float4 inds=round(indices*255);
    for(int i=0;i<4;++i)
    {
        position+=mul(BoneMatrices[inds.x],sourcePos).xyz*weights.x;
        normal+=mul((float3x3)BoneMatrices[inds.x],sourceNormal)*weights.x;
        tangent.xyz+=mul((float3x3)BoneMatrices[inds.x],sourceTangent.xyz)*weights.x;
        
        weights=weights.yzwx;
        inds=inds.yzwx;            }
}


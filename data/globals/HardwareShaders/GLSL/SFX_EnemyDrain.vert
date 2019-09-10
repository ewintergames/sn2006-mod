
// #class Object

#include "std.gh"
#include "fog.gh"

// #default Noise1 = 0.1543543  0.7         20    0
// #default Noise2 = -0.92442    0.03235432   16     0
// #default EffectPosition = 1
// #default EffectClampScale = 16

uniform vec4 EyeInObjectSpace;
uniform vec4 FogParams;
uniform float FrameTime;
uniform vec4 VectorParam1_Noise1;
uniform vec4 VectorParam2_Noise2;
uniform float FloatParam1_EffectPosition;
uniform float FloatParam2_EffectClampScale;
uniform vec2 Blend;


varying vec4 position;
varying vec2 uv0;
varying vec2 noise1UV, noise2UV;
varying vec4 color;

void main()
{
    gl_Position = ftransform();
    uv0 = gl_MultiTexCoord0.st;
    
    vec2 uvVec=uv0-vec2(0.5,0.7);
    float uvL=length(uvVec);
    
    noise1UV = vec2(uvL,uv0.x)*VectorParam1_Noise1.zy+vec2(fract(VectorParam1_Noise1.x*FrameTime),0);
    noise2UV = vec2(uv0.y,uvL)*VectorParam2_Noise2.zy+vec2(0,fract(VectorParam2_Noise2.x*FrameTime));
    
    uvL/=0.7;
    float clampDown = saturate(FloatParam2_EffectClampScale*(uvL+saturate(FloatParam1_EffectPosition)-1.0));
    float clampUp = saturate(FloatParam2_EffectClampScale*(1.0-uvL-saturate(FloatParam1_EffectPosition-1.0)));
    float intensity = clampDown*clampUp;
    
    float fog=1.0-fogFactor(gl_Vertex.xyz,EyeInObjectSpace.xyz,FogParams);
    color = vec4(intensity,intensity,intensity, Blend.x*fog);
}



varying vec4 position;
varying vec2 uv0;
varying vec2 noise1UV, noise2UV;
varying vec4 color;

uniform sampler2D Texture0;
uniform sampler2D Texture1_Noise;
uniform vec4 VectorParam3_ExtraColor;
uniform float FloatParam7_HighlightScale;
uniform vec4 VectorParam7_AdditiveColor;

// #default AdditiveColor = 1 1 1 0
// #default Texture1_Noise = sfx\firenoise.tga
// #default ExtraColor = 0 0 0 0
// #default HighlightScale = 2

#include "std.gh"

void main()
{
    vec4 src=vec4 (VectorParam3_ExtraColor.xyz,texture2D(Texture0,uv0).x);
    float noiseMask=src.w;

    vec3 noise1=texture2D(Texture1_Noise,noise1UV).xyz;
    vec3 noise2=texture2D(Texture1_Noise,noise2UV).xyz;
    vec3 noise=noise1*noise2;

    noise=saturate(noise*FloatParam7_HighlightScale);
    src.xyz=saturate(src.xyz+(VectorParam7_AdditiveColor.xyz*noise)*noiseMask);
    
    gl_FragColor=vec4(src.xyz*color.xyz,color.w);
}


// #class Object


varying vec4 position;
varying vec2 uv0;
varying vec4 diffuse;

#define MAX_SKINNING_BONES  40

#include "std.gh"
#include "skinning.gh"

void main()
{
    vec3 pos;
    pos=Skin(gl_Vertex);
    
    gl_Position = gl_ModelViewProjectionMatrix * vec4(pos,1);
    uv0 = gl_MultiTexCoord0.st;
    diffuse=vec4(1,1,1,1);
}


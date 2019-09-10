// #class Object


varying vec4 position;
varying vec2 uv0;
varying vec4 diffuse;

#define MAX_SKINNING_BONES  40
#define MAX_LIGHTS  4

#include "std.gh"
#include "skinning.gh"
#include "lighting.gh"

void main()
{
    vec3 pos, norm;
    pos=Skin(gl_Vertex);
//    norm=vec3(gl_Normal.xyz); //Skin(vec4(gl_Normal.xyz,0));

    gl_Position = gl_ModelViewProjectionMatrix * vec4(pos,1);
    
    uv0 = gl_MultiTexCoord0.st;
/*    
    vec3 color=vec3(1,1,1);//vertexDiffuse(pos,norm);
    diffuse = vec4(color,1);
*/    
    diffuse = vec4(1,1,1,1);
}


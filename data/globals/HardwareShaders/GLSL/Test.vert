// #class Object

varying vec2 textureUV;

//---------------------------------------------------------
void main()
{
    gl_Position = ftransform();
    textureUV = gl_MultiTexCoord0.st;
}

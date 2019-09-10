uniform sampler2D Texture0;
uniform vec4 VectorParam1_ConstantColor;

varying vec2 textureUV;

// #default ConstantColor = 1 1 1 1

//---------------------------------------------------------
void main()
{
    vec4 txt=texture2D(Texture0,textureUV);
    gl_FragColor = txt*VectorParam1_ConstantColor;
}




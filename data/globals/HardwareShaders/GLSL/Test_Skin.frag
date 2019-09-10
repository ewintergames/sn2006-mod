
varying vec4 position;
varying vec2 uv0;
varying vec4 diffuse;

uniform sampler2D Texture0;

void main()
{
    vec4 txt=texture2D(Texture0,uv0);
    gl_FragColor=txt*diffuse;
}


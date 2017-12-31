varying highp vec2 textureCoordinate;
uniform sampler2D src;
                                 
void main(void)
{
 vec2 Tex0 = textureCoordinate;
 
 vec4 a = texture2D(src, Tex0);
 
 gl_FragColor = vec4(1.0 - a.x, 1.0 - a.y, 1.0 - a.z, 1.0);
}

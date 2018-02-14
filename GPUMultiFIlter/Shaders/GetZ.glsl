varying highp vec2 textureCoordinate;
uniform sampler2D src;
                                 
void main(void)
{
 highp vec2 Tex0 = textureCoordinate;
 
 highp vec4 a = texture2D(src, Tex0);
 
 gl_FragColor = vec4(1.0 - a.z, 1.0 - a.z, 1.0 - a.z, 1.0);
}

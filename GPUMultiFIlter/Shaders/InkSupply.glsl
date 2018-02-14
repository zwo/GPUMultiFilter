varying highp vec2 textureCoordinate;
uniform sampler2D VelDenMap;
uniform sampler2D SurfInkMap;
uniform sampler2D MiscMap;

void main(void)
{
 highp vec2 Tex0 = textureCoordinate;

 highp vec4 is = texture2D(SurfInkMap, Tex0);
 highp float ws = texture2D(MiscMap, Tex0).w;
 highp float seep = texture2D(VelDenMap, Tex0).w;
 
 is = (ws <= 0.001) ? vec4(0.0, 0.0, 0.0, 0.0) : is;
 
 gl_FragColor = is;
}

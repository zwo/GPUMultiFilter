varying highp vec2 textureCoordinate;

uniform sampler2D Grain;
uniform sampler2D Alum;
uniform sampler2D Pinning;

void main(void)
{
 highp vec2 Tex0 = textureCoordinate;
 
 highp vec4 g = texture2D(Grain, Tex0);
 highp vec4 a = texture2D(Alum, Tex0);
 highp vec4 p = texture2D(Pinning, Tex0);
 
 lowp float gg = (g.x + g.y + g.z) / 3.0;
 lowp float aa = (a.x + a.y + a.z) / 3.0;
 lowp float pp = (p.x + p.y + p.z) / 3.0;
 lowp float co = 1.0;
 
 gg *= co;
 aa *= co;
 pp *= co;
 
 gl_FragColor = vec4(gg, 1.0, aa, pp);
}

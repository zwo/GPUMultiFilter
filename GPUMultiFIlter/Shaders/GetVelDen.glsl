varying highp vec2 textureCoordinate;
uniform mediump float wf_mul;
uniform mediump float Evapor;

uniform sampler2D MiscMap;
uniform sampler2D Dist1Map;
uniform sampler2D Dist2Map;
uniform sampler2D VelDenMap;

void main(void)
{
 highp vec2 Tex0 = textureCoordinate;
 
 highp vec4 Misc0 = texture2D(MiscMap, Tex0);
 mediump float f0 = Misc0.y;
 mediump float ws = Misc0.w;
 
 highp vec4 Dist1 = texture2D(Dist1Map, Tex0);
 highp vec4 Dist2 = texture2D(Dist2Map, Tex0);
 mediump vec2 v;
 v.x = (Dist1.y + Dist2.x + Dist2.y) - (Dist1.z + Dist2.z + Dist2.w);
 v.y = (Dist1.w + Dist2.y + Dist2.w) - (Dist1.x + Dist2.x + Dist2.z);
 
 mediump vec4 tmp = Dist1 + Dist2;
 mediump float wf = f0 + tmp.x + tmp.y + tmp.z + tmp.w;
 
 wf *= wf_mul;
 wf = max(wf - Evapor, 0.0);
 mediump float seep = clamp(ws / 15.0, 0.0, max(1.0 - wf, 0.0));
 wf += seep;
 
 gl_FragColor = vec4(v.x, v.y, wf, seep);
}

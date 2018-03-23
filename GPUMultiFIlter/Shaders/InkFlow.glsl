varying highp vec2 textureCoordinate;
uniform sampler2D VelDenMap;
uniform sampler2D MiscMap;
uniform sampler2D Dist1Map;
uniform sampler2D Dist2Map;
uniform sampler2D FlowInkMap;
uniform sampler2D SurfInkMap;

uniform highp vec2 Blk_a;
uniform highp vec2 offset;

void main(void)
{
 highp vec2 Tex0 = textureCoordinate;
 
 highp float dx=offset.x;
 highp float dy=offset.y;
 
 highp vec4 TexN_NE = vec4(Tex0.x,      Tex0.y - dy, Tex0.x + dx, Tex0.y - dy);
 highp vec4 TexE_SE = vec4(Tex0.x + dx, Tex0.y,      Tex0.x + dx, Tex0.y + dy);
 highp vec4 TexW_NW = vec4(Tex0.x - dx, Tex0.y,      Tex0.x - dx, Tex0.y - dy);
 highp vec4 TexS_SW = vec4(Tex0.x,      Tex0.y + dy, Tex0.x - dx, Tex0.y + dy);
 
 highp vec2 u = texture2D(VelDenMap, Tex0).xy;
 highp float seep = texture2D(VelDenMap, Tex0).w;
 
 highp vec2 ucoord = vec2(dx * u.x, dy * u.y);
 
 highp float f1 = texture2D(Dist1Map, Tex0).x;
 highp float f2 = texture2D(Dist1Map, Tex0).y;
 highp float f3 = texture2D(Dist1Map, Tex0).z;
 highp float f4 = texture2D(Dist1Map, Tex0).w;
 
 highp float f5 = texture2D(Dist2Map, Tex0).x;
 highp float f6 = texture2D(Dist2Map, Tex0).y;
 highp float f7 = texture2D(Dist2Map, Tex0).z;
 highp float f8 = texture2D(Dist2Map, Tex0).w;
 
 highp float wf = texture2D(VelDenMap, Tex0).z;
 highp float lwf = texture2D(MiscMap, Tex0).z;
 
 highp vec4 pf1 = texture2D(FlowInkMap, TexS_SW.xy);
 highp vec4 pf2 = texture2D(FlowInkMap, TexW_NW.xy);
 highp vec4 pf3 = texture2D(FlowInkMap, TexE_SE.xy);
 highp vec4 pf4 = texture2D(FlowInkMap, TexN_NE.xy);
 
 highp vec4 pf5 = texture2D(FlowInkMap, TexS_SW.zw);
 highp vec4 pf6 = texture2D(FlowInkMap, TexW_NW.zw);
 highp vec4 pf7 = texture2D(FlowInkMap, TexE_SE.zw);
 highp vec4 pf8 = texture2D(FlowInkMap, TexN_NE.zw);
 
 highp vec4 iFill;
 highp vec4 iStream;
 highp vec4 is = texture2D(SurfInkMap, Tex0);
 
 bool JustFilled;
 highp vec4 pf;
 highp vec4 ia;
 
 if (lwf == 0.0 && wf != 0.0)
     JustFilled = true;
 else
     JustFilled = false;
 
 iFill = (f1*pf1+f2*pf2+f3*pf3+f4*pf4+f5*pf5+f6*pf6+f7*pf7+f8*pf8) / wf;
 
 if (abs(u.x) < dx && abs(u.y) < dy)
     iStream = texture2D(FlowInkMap, Tex0);
 else
     iStream = texture2D(FlowInkMap, Tex0 - u);
 
 lowp float Blk_hindrance = mix(1.0, Blk_a.x, smoothstep(0.0, Blk_a.y, sqrt(u.x * u.x + u.y * u.y)));
 ia = mix((JustFilled) ? iFill : iStream, texture2D(FlowInkMap, Tex0), Blk_hindrance);
 
 if (seep != 0.0)
     pf = (ia * lwf + is * seep) / (lwf + seep);
 else
     pf = ia;
 
 gl_FragColor = pf;
}

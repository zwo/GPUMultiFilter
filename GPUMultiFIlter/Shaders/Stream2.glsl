varying highp vec2 textureCoordinate;

uniform sampler2D MiscMap;
uniform sampler2D Dist2Map;

uniform highp float Evapor_b;
uniform highp vec2 offset;

void main(void)
{
 highp float dx = offset.s;
 highp float dy = offset.t;
 
 highp vec2 Tex0 = textureCoordinate;
 
 highp vec4 TexN_NE = vec4(Tex0.x,      Tex0.y - dy, Tex0.x + dx, Tex0.y - dy);
 highp vec4 TexE_SE = vec4(Tex0.x + dx, Tex0.y,      Tex0.x + dx, Tex0.y + dy);
 highp vec4 TexW_NW = vec4(Tex0.x - dx, Tex0.y,      Tex0.x - dx, Tex0.y - dy);
 highp vec4 TexS_SW = vec4(Tex0.x,      Tex0.y + dy, Tex0.x - dx, Tex0.y + dy);
 
 highp float b0 = texture2D(MiscMap, Tex0).x;
 highp float bNE = texture2D(MiscMap, TexN_NE.zw).x;
 highp float bSE = texture2D(MiscMap, TexE_SE.zw).x;
 highp float bNW = texture2D(MiscMap, TexW_NW.zw).x;
 highp float bSW = texture2D(MiscMap, TexS_SW.zw).x;
 
 highp vec4 b = vec4(bSW, bNW, bSE, bNE);
 b = (b + b0) / 2.0;
 
 highp vec4 pinned = vec4(b.x > 1.0, b.y > 1.0, b.z > 1.0, b.w > 1.0);
 b = min(b, 1.0);
 highp vec4 f_Out;
 highp vec4 f_In;
 
 f_Out = texture2D(Dist2Map, Tex0);
 f_In.x = texture2D(Dist2Map, TexS_SW.zw).x;
 f_In.y = texture2D(Dist2Map, TexW_NW.zw).y;
 f_In.z = texture2D(Dist2Map, TexE_SE.zw).z;
 f_In.w = texture2D(Dist2Map, TexN_NE.zw).w;
 
 highp vec4 OUT = mix(f_In, f_Out.wzyx, b);
 
 gl_FragColor = max(OUT - pinned * Evapor_b, 0.0);
}

varying highp vec2 textureCoordinate;

uniform sampler2D MiscMap;
uniform sampler2D Dist1Map;

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
 highp float bN = texture2D(MiscMap, TexN_NE.xy).x;
 highp float bE = texture2D(MiscMap, TexE_SE.xy).x;
 highp float bW = texture2D(MiscMap, TexW_NW.xy).x;
 highp float bS = texture2D(MiscMap, TexS_SW.xy).x;
 
 highp vec4 b = vec4(bS, bW, bE, bN);
 b = (b + b0) / 2.0;
 
 highp vec4 pinned = vec4(b.x > 1.0, b.y > 1.0, b.z > 1.0, b.w > 1.0);
 b = min(b, 1.0);
 highp vec4 f_Out;
 highp vec4 f_In;
 
 f_Out = texture2D(Dist1Map, Tex0);
 f_In.x = texture2D(Dist1Map, TexS_SW.xy).x;
 f_In.y = texture2D(Dist1Map, TexW_NW.xy).y;
 f_In.z = texture2D(Dist1Map, TexE_SE.xy).z;
 f_In.w = texture2D(Dist1Map, TexN_NE.xy).w;
 
 highp vec4 OUT = mix(f_In, f_Out.wzyx, b);
 
 gl_FragColor = max(OUT - pinned * Evapor_b, 0.0);
}

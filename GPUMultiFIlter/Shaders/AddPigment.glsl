varying highp vec2 textureCoordinate;

uniform sampler2D SurfInk;
uniform sampler2D WaterSurface;
uniform sampler2D Misc;

uniform highp float gamma;
uniform highp float baseMask;

void main(void)
{
 highp vec2 Tex0 = textureCoordinate;

 highp vec4 is = texture2D(SurfInk, Tex0);
 highp vec4 wa = texture2D(WaterSurface, Tex0);
 highp vec4 mi = texture2D(Misc, Tex0);
 
 highp float DepMask = max(1.0 - mi.z / gamma, baseMask);
 
 highp float re = is.x + clamp(wa.x, 0.0, DepMask);
 highp float gr = is.y + clamp(wa.y, 0.0, DepMask);
 highp float bl = is.z + clamp(wa.z, 0.0, DepMask);
 
 gl_FragColor = vec4(re, gr, bl, is.w);

}

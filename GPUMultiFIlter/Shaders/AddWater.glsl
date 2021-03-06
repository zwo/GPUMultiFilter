varying highp vec2 textureCoordinate;

uniform sampler2D Misc;
uniform sampler2D WaterSurface;

uniform highp float gamma;
uniform highp float baseMask;
uniform highp float waterAmount;

void main(void)
{
 highp vec2 Tex0 = textureCoordinate;
 
 highp vec4 mi = texture2D(Misc, Tex0);
 highp vec4 wa = texture2D(WaterSurface, Tex0);
 highp float DepMask = max(1.0 - mi.z / gamma, baseMask);
 
 highp float temp_waterAmount = 0.0;
 
 if (wa.w != 0.0)
 {
     temp_waterAmount = waterAmount;
 }
 
 gl_FragColor = vec4(mi.xyz, mi.w + clamp(temp_waterAmount, 0.0, DepMask));
}

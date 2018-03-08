varying highp vec2 textureCoordinate;


uniform sampler2D WaterSurface;

void main(void)
{
 highp vec2 Tex0 = textureCoordinate;


 highp vec4 wa = texture2D(WaterSurface, Tex0);
 
 highp vec2 xy = 2.0 * textureCoordinate - 1.0;
 mediump vec4 foreColor = vec4(0.5,0.5,0.0,1);
 mediump float pos = 0.1;
 mediump vec4 color = wa;
 if (xy.x<(pos+0.1) && xy.x>pos) {
     color = mix(color,foreColor,0.5);
 }
 
 gl_FragColor = color;
}
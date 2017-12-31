varying highp vec2 textureCoordinate;
uniform sampler2D FixInkMap;
uniform sampler2D SinkInkMap;
uniform sampler2D velDen;
uniform float bEvaporToDisapper; // false = 0, true = 1

void main(void)
{
 vec2 Tex0 = textureCoordinate;
 
 vec4 sink = texture2D(SinkInkMap, Tex0);
 vec4 ix0 = texture2D(FixInkMap, Tex0);
 vec4 ix_new = sink + ix0;
 ix_new = vec4(ix_new.xyz, (ix_new.x + ix_new.y + ix_new.z) / 3.0);
 
 if (bEvaporToDisapper == 1.0)
 {
     vec4 a = texture2D(velDen, Tex0);
     if (a.z <= 0.001)
         gl_FragColor = vec4(ix_new.rgb * (a.z * 990.0), ix_new.a);
     else
         gl_FragColor = ix_new;
 }
 else
 {
     gl_FragColor = ix_new;
 }
}

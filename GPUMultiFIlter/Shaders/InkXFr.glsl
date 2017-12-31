varying highp vec2 textureCoordinate;
uniform sampler2D FlowInkMap;
uniform sampler2D SinkInkMap;

void main(void)
{
 vec2 Tex0 = textureCoordinate;
 
 vec4 sink = texture2D(SinkInkMap, Tex0);
 vec4 if0 = texture2D(FlowInkMap, Tex0);
 vec4 if_new = if0 - sink;
 
 gl_FragColor = if_new;
}

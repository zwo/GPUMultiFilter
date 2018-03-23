varying highp vec2 textureCoordinate;
uniform sampler2D FlowInkMap;
uniform sampler2D SinkInkMap;

void main(void)
{
 highp vec2 Tex0 = textureCoordinate;
 
 highp vec4 sink = texture2D(SinkInkMap, Tex0);
 highp vec4 if0 = texture2D(FlowInkMap, Tex0);
 highp vec4 if_new = if0 - sink;
 
 gl_FragColor = if_new;
}

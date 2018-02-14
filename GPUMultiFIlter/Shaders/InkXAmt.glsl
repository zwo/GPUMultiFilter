varying highp vec2 textureCoordinate;
uniform sampler2D VelDenMap;
uniform sampler2D MiscMap;
uniform sampler2D FlowInkMap;
uniform sampler2D FixInkMap;

lowp uniform vec3 FixRate;

void main(void)
{
 highp vec2 Tex0 = textureCoordinate;
 
 highp float lwf = texture2D(MiscMap, Tex0).z;
 highp float wf = texture2D(VelDenMap, Tex0).z;
 highp vec4 if0 = texture2D(FlowInkMap, Tex0);
 
 lowp float wLoss = max(lwf - wf, 0.0);
 lowp float FixFactor;
 
 if (wLoss > 0.0)
     FixFactor = wLoss / lwf;
 else
     FixFactor = 0.0;
 
 lowp float mu_star = clamp(FixRate.y + FixRate.z * if0.w, 0.0, 1.0);
 FixFactor = max(FixFactor * (1.0 - smoothstep(0.0, mu_star, wf)), FixRate.x);
 
 lowp vec4 sink = if0 * FixFactor;
 
 gl_FragColor = sink;
}

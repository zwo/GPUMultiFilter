precision highp float;
varying vec2 textureCoordinate;

uniform highp float A;
uniform highp float B;
uniform highp float C;
uniform highp float D;
uniform highp float advect_p;
uniform highp float Omega;

uniform sampler2D VelDenMap;
uniform sampler2D Dist1Map;
uniform sampler2D InkMap;

void main(void)
{
 vec2 Tex0 = textureCoordinate;
 
 vec4 VelDen = texture2D(VelDenMap, Tex0);
 
 vec2 v = VelDen.xy;
 float p = VelDen.z;
 vec4 eiDotv = vec4(-v.y, v.x, -v.x, v.y);
 float ad = smoothstep(0.0, advect_p, p);
 
 vec4 f_eq = A * p + ad * (B * eiDotv + C * eiDotv * eiDotv - D * dot(v, v));
 vec4 f = texture2D(Dist1Map, Tex0);
 
 gl_FragColor = mix(f, f_eq, Omega);
}

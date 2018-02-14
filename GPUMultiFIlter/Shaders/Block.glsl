varying highp vec2 textureCoordinate;

uniform mediump float A0;
uniform mediump float advect_p;
uniform mediump vec3 Blk_1;
uniform mediump vec2 Blk_2;
uniform mediump vec3 Pin_w;
uniform mediump float toe_p;
uniform mediump float Omega;
uniform mediump float Corn_mul;
uniform mediump vec2 offset;

uniform sampler2D MiscMap;
uniform sampler2D VelDenMap;
uniform sampler2D FlowInkMap;
uniform sampler2D FixInkMap;
uniform sampler2D DisorderMap;

void main(void){
 
 mediump float dx = offset.s;
 mediump float dy = offset.t;
 
 highp vec2 Tex0 = textureCoordinate;
 
 highp vec4 TexN_NE = vec4(Tex0.x,      Tex0.y - dy, Tex0.x + dx, Tex0.y - dy);
 highp vec4 TexE_SE = vec4(Tex0.x + dx, Tex0.y,      Tex0.x + dx, Tex0.y + dy);
 highp vec4 TexW_NW = vec4(Tex0.x - dx, Tex0.y,      Tex0.x - dx, Tex0.y - dy);
 highp vec4 TexS_SW = vec4(Tex0.x,      Tex0.y + dy, Tex0.x - dx, Tex0.y + dy);
 
 highp vec4 Misc0 = texture2D(MiscMap, Tex0);
 highp vec4 VelDen = texture2D(VelDenMap, Tex0);
 
 mediump float f0 = Misc0.y;
 mediump float ws = Misc0.w;
 mediump vec2 v = VelDen.xy;
 mediump float wf = VelDen.z;
 mediump float seep = VelDen.w;
 
 highp float glue = texture2D(FlowInkMap, Tex0).w;
 highp float FixBlk = texture2D(FixInkMap, Tex0).w;
 
 highp vec4 Disorder = texture2D(DisorderMap, Tex0);
 
 // Derive ad: Less advection for lower wf
 mediump float ad = smoothstep(0.0, advect_p, wf);
 
 // Derive f0
 mediump float f0_eq = A0 * wf - ad * (2.0 / 3.0) * dot(v, v);
 f0 = mix(f0, f0_eq, Omega);
 
 mediump float GrainBlock = Disorder.x;
 mediump float AlumBlock = Disorder.z;
 mediump float block = Blk_1.x + dot(Blk_1.yz, vec2(GrainBlock, AlumBlock)) + dot(Blk_2.xy, vec2(glue, FixBlk));
 block = min(1.0, block);
 bool pinning = (wf == 0.0);
 
 mediump float Pindisor = mix(Disorder.x, Disorder.w, smoothstep(0.0, toe_p, glue));
 mediump float pin = Pin_w.x + dot(Pin_w.yz, vec2(FixBlk, Pindisor));
 
 pinning = (pinning) && (texture2D(VelDenMap, TexN_NE.xy).z < pin);
 pinning = (pinning) && (texture2D(VelDenMap, TexE_SE.xy).z < pin);
 pinning = (pinning) && (texture2D(VelDenMap, TexW_NW.xy).z < pin);
 pinning = (pinning) && (texture2D(VelDenMap, TexS_SW.xy).z < pin);
 
 pin *= Corn_mul;
 
 pinning = (pinning) && (texture2D(VelDenMap, TexN_NE.zw).z < pin);
 pinning = (pinning) && (texture2D(VelDenMap, TexE_SE.zw).z < pin);
 pinning = (pinning) && (texture2D(VelDenMap, TexW_NW.zw).z < pin);
 pinning = (pinning) && (texture2D(VelDenMap, TexS_SW.zw).z < pin);
 
 if (pinning)
     block = 1.0/0.0;
 
 gl_FragColor = vec4(block, f0, wf, max(ws - seep, 0.0));
} 
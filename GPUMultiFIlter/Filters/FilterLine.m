//
//  FilterLine.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2017/12/28.
//  Copyright © 2017年 周维鸥. All rights reserved.
//

#import "FilterLine.h"

static NSString *const kLineFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform float pos;
 
 void main()
 {
     float aperture = 0.5;
     vec4 foreColor = vec4(0.5,0.5,0.0,1);
     vec2 uv=textureCoordinate;
     vec2 xy = 2.0 * textureCoordinate - 1.0;
     vec4 color = texture2D(inputImageTexture, uv);
     if (xy.x<(pos+0.1) && xy.x>pos) {
         color = mix(color,foreColor,0.5);
     }
     
     gl_FragColor = color;
 }
 );

@implementation FilterLine
{
    GLint _posUniform;
}

- (instancetype)init
{
    if (self=[super initWithFragmentShaderFromString:kLineFilterFragmentShaderString]) {
        _posUniform=[filterProgram uniformIndex:@"pos"];
    }
    return self;
}

- (void)setPos:(CGFloat)pos
{
    _pos=pos;
    [self setFloat:pos forUniform:_posUniform program:filterProgram];
}

@end

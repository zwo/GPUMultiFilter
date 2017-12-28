//
//  FilterCircle.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2017/12/28.
//  Copyright © 2017年 周维鸥. All rights reserved.
//

#import "FilterCircle.h"

static NSString *const kCircleFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 const float PI = 3.1415926535;
 
 void main()
 {
     float aperture = 0.5;
     vec4 foreColor = vec4(0.5,0.5,0.5,1);
     vec2 uv=textureCoordinate;
     vec2 xy = 2.0 * textureCoordinate - 1.0;
     float d = length(xy);
     vec4 color = texture2D(inputImageTexture, uv);
     if (d < aperture) {
         color = mix(color,foreColor,0.5);
     }     
     
     gl_FragColor = color;
 }
 );

@implementation FilterCircle

- (instancetype)init
{
    if (self=[super initWithFragmentShaderFromString:kCircleFilterFragmentShaderString]) {
        //
    }
    return self;
}

@end

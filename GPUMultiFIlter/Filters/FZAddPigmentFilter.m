//
//  FZAddPigmentFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/12.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZAddPigmentFilter.h"

@implementation FZAddPigmentFilter
{
    GLint _pxSizeUniform;
}
- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"AddPigment" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    _pxSizeUniform=[filterProgram uniformIndex:@"pxSize"];
    
    return self;
}

@end

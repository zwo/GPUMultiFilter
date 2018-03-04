//
//  FZXYZ4OutputDebugFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/3/4.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZXYZ4OutputDebugFilter.h"

static const GLfloat debugOutput4_4[] = {
    0.0f, 0.0f,
    1.0f, 0.0f,
    0.0f,  1.0f,
    1.0f,  1.0f,
}; // num 4 quad

static const GLfloat debugOutput3_4[] = {
    -1.0f, 0.0f,
    0.0f, 0.0f,
    -1.0f,  1.0f,
    0.0f,  1.0f,
}; // num 3 quad

static const GLfloat debugOutput2_4[] = {
    -1.0f, -1.0f,
    0.0f, -1.0f,
    -1.0f,  0.0f,
    0.0f,  0.0f,
}; // num 2 quad

static const GLfloat debugOutput1_4[] = {
    0.0f, -1.0f,
    1.0f, -1.0f,
    0.0f,  0.0f,
    1.0f,  0.0f,
}; // num 1 quad

@implementation FZXYZ4OutputDebugFilter
{
    GLuint _sourceTextureUniform;
}

- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"GetXYZ" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    _sourceTextureUniform=[filterProgram uniformIndex:@"src"];
    return self;
}

- (void)begin
{
    [GPUImageContext setActiveShaderProgram:filterProgram];
    outputFramebuffer=self.renderFramebuffer;
    [outputFramebuffer activateFramebuffer];
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
}

- (void)end
{
    self.renderFramebuffer=nil;
}

- (void)renderFramebuffer:(GPUImageFramebuffer *)framebuffer toGuadrant:(NSInteger)index
{
    const GLfloat *vertices;
    switch (index) {
        case 1:
            vertices=debugOutput1_4;
            break;
        case 2:
            vertices=debugOutput2_4;
            break;
        case 3:
            vertices=debugOutput3_4;
            break;
        case 4:
            vertices=debugOutput4_4;
            break;
        default:
            vertices=debugOutput1_4;
            break;
    }
    
    static const GLfloat noRotationTextureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    glBindTexture(GL_TEXTURE_2D, [framebuffer texture]);
    glUniform1i(_sourceTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, noRotationTextureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}
@end

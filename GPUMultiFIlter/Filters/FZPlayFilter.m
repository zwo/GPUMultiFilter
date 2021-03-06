//
//  FZPlayFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/3/8.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZPlayFilter.h"

@implementation FZPlayFilter
{
    GPUImageFramebuffer *_waterSurfaceFramebuffer;
    GLuint _waterSurfaceTextureUniform;
    GLuint _posUniform;
}

- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"Play" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    _waterSurfaceTextureUniform=[filterProgram uniformIndex:@"WaterSurface"];
    _posUniform=[filterProgram uniformIndex:@"pos"];
    return self;
}

- (void)setPos:(CGFloat)pos
{
    _pos=pos;
    [self setFloat:pos forUniform:_posUniform program:filterProgram];
}

- (void)setWaterSurfaceFramebuffer:(GPUImageFramebuffer *)waterSurfaceFramebuffer
{
    _waterSurfaceFramebuffer=waterSurfaceFramebuffer;
    [_waterSurfaceFramebuffer lock];
    [self setInputSize:waterSurfaceFramebuffer.size atIndex:0];
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    [GPUImageContext setActiveShaderProgram:filterProgram];
    if (self.renderFramebuffer)
    {
        outputFramebuffer=self.renderFramebuffer;
    }else{
        outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    }
    [outputFramebuffer activateFramebuffer];
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [_waterSurfaceFramebuffer texture]);
    glUniform1i(_waterSurfaceTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [_waterSurfaceFramebuffer unlock];    
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:kGPUImageFlipVertical]];
    
    [self informTargetsAboutNewFrameAtTime:frameTime];
}

@end

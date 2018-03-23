//
//  FZAddWaterFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZAddWaterFilter.h"

@implementation FZAddWaterFilter
{
    GLuint _gammaUniform;
    GLuint _baseMaskUniform;
    GLuint _waterAmountUniform;
    GLuint _miscTextureUniform;
    GLuint _waterSurfaceTextureUniform;
    GPUImageFramebuffer *_miscFramebuffer;
    GPUImageFramebuffer *_waterSurfaceFramebuffer;
}

- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"AddWater" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    _gammaUniform=[filterProgram uniformIndex:@"gamma"];
    _baseMaskUniform=[filterProgram uniformIndex:@"baseMask"];
    _waterAmountUniform=[filterProgram uniformIndex:@"waterAmount"];
    _miscTextureUniform=[filterProgram uniformIndex:@"Misc"];
    _waterSurfaceTextureUniform=[filterProgram uniformIndex:@"WaterSurface"];
    return self;
}

- (void)setGamma:(CGFloat)newValue
{
    _gamma=newValue;
    [self setFloat:newValue forUniform:_gammaUniform program:filterProgram];
}

- (void)setBaseMask:(CGFloat)newValue
{
    _baseMask=newValue;
    [self setFloat:newValue forUniform:_baseMaskUniform program:filterProgram];
}

- (void)setWaterAmount:(CGFloat)waterAmount
{
    _waterAmount=waterAmount;
    [self setFloat:waterAmount forUniform:_waterAmountUniform program:filterProgram];
}

- (void)setMiscFramebuffer:(GPUImageFramebuffer *)miscFramebuffer waterSurfaceFramebuffer:(GPUImageFramebuffer *)waterSurfaceFramebuffer
{
    _miscFramebuffer=miscFramebuffer;
    _waterSurfaceFramebuffer=waterSurfaceFramebuffer;
    [_miscFramebuffer lock];
    [_waterSurfaceFramebuffer lock];
    [self setInputSize:miscFramebuffer.size atIndex:0];
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
    glBindTexture(GL_TEXTURE_2D, [_miscFramebuffer texture]);
    glUniform1i(_miscTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [_waterSurfaceFramebuffer texture]);
    glUniform1i(_waterSurfaceTextureUniform, 3);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    GLenum err = glGetError();
    if (err != GL_NO_ERROR) {
        NSLog(@"%s glerr %zd ",__PRETTY_FUNCTION__,err);
    }
    
    [_waterSurfaceFramebuffer unlock];
    [_miscFramebuffer unlock];

}

@end

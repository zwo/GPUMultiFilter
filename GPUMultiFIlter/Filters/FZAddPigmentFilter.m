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
    GLint _surfInkTextureUniform;
    GLint _waterSurfaceTextureUniform;
    GLint _miscInkTextureUniform;
    GLint _gammaUniform;
    GLint _baseMaskUniform;
    GPUImageFramebuffer *_surfInkFramebuffer;
    GPUImageFramebuffer *_waterSurfaceFramebuffer;
    GPUImageFramebuffer *_miscFramebuffer;
}
- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"AddPigment" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    _surfInkTextureUniform=[filterProgram uniformIndex:@"SurfInk"];
    _waterSurfaceTextureUniform=[filterProgram uniformIndex:@"WaterSurface"];
    _miscInkTextureUniform=[filterProgram uniformIndex:@"Misc"];

    _gammaUniform=[filterProgram uniformIndex:@"gamma"];
    _baseMaskUniform=[filterProgram uniformIndex:@"baseMask"];
    _nextAvailableTextureIndex=-1;
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

- (void)setSurfInkFramebuffer:(GPUImageFramebuffer *)surfInkFramebuffer waterSurfaceFramebuffer:(GPUImageFramebuffer *)waterSurfaceFramebuffer miscFramebuffer:(GPUImageFramebuffer *)miscFramebuffer;
{
	_surfInkFramebuffer=surfInkFramebuffer;
	_waterSurfaceFramebuffer=waterSurfaceFramebuffer;
	_miscFramebuffer=miscFramebuffer;
	[_surfInkFramebuffer lock];
	[_waterSurfaceFramebuffer lock];
	[_miscFramebuffer lock];
    [self setInputSize:surfInkFramebuffer.size atIndex:0];

}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    [GPUImageContext setActiveShaderProgram:filterProgram];
    // TODO: ping pong
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];

    [self setUniformsForProgramAtIndex:0];
        
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
	glActiveTexture(GL_TEXTURE2);
	glBindTexture(GL_TEXTURE_2D, [_surfInkFramebuffer texture]);
	glUniform1i(_surfInkTextureUniform, 2);	
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [_waterSurfaceFramebuffer texture]);
    glUniform1i(_waterSurfaceTextureUniform, 3);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [_miscFramebuffer texture]);
    glUniform1i(_miscInkTextureUniform, 4);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [_surfInkFramebuffer unlock];
	[_waterSurfaceFramebuffer unlock];
	[_miscFramebuffer unlock];
}
@end

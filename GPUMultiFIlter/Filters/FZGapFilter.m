//
//  FZGapFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZGapFilter.h"

@implementation FZGapFilter
{
	GLuint _GrainTextureUniform;
	GLuint _AlumTextureUniform;
	GLuint _PinningTextureUniform;
	GPUImageFramebuffer *_GrainFramebuffer;
	GPUImageFramebuffer *_AlumFramebuffer;
	GPUImageFramebuffer *_PinningFramebuffer;
}

- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"Gap" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
	_GrainTextureUniform=[filterProgram uniformIndex:@"Grain"];
	_AlumTextureUniform=[filterProgram uniformIndex:@"Alum"];
	_PinningTextureUniform=[filterProgram uniformIndex:@"Pinning"];

    return self;
}

- (void)setGrainFramebuffer:(GPUImageFramebuffer *)GrainFramebuffer alumFramebuffer:(GPUImageFramebuffer *)AlumFramebuffer pinningFramebuffer:(GPUImageFramebuffer *)PinningFramebuffer
{
	_GrainFramebuffer=GrainFramebuffer;
	_AlumFramebuffer=AlumFramebuffer;
	_PinningFramebuffer=PinningFramebuffer;
	[_GrainFramebuffer lock];
	[_AlumFramebuffer lock];
	[_PinningFramebuffer lock];
	[self setInputSize:GrainFramebuffer.size atIndex:0];
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
	glBindTexture(GL_TEXTURE_2D, [_GrainFramebuffer texture]);
	glUniform1i(_GrainTextureUniform, 2);	
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [_AlumFramebuffer texture]);
    glUniform1i(_AlumTextureUniform, 3);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [_PinningFramebuffer texture]);
    glUniform1i(_PinningTextureUniform, 4);    
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    GLenum err = glGetError();
    if (err != GL_NO_ERROR) {
        NSLog(@"%s glerr %zd ",__PRETTY_FUNCTION__,err);
    }

    [_GrainFramebuffer unlock];
	[_AlumFramebuffer unlock];
	[_PinningFramebuffer unlock];
}
@end

//
//  FZInkSupplyFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZInkSupplyFilter.h"

@implementation FZInkSupplyFilter
{
	GLuint _VelDenMapUniform;
	GLuint _SurfInkMapUniform;
	GLuint _MiscMapUniform;
	GPUImageFramebuffer *_VelDenMapFramebuffer;
	GPUImageFramebuffer *_SurfInkMapFramebuffer;
	GPUImageFramebuffer *_MiscMapFramebuffer;
}

- (void)setVelDenMap:(GPUImageFramebuffer *)VelDenMapFramebuffer surfInkMap:(GPUImageFramebuffer *)SurfInkMapFramebuffer miscMap:(GPUImageFramebuffer *)MiscMapFramebuffer
{
	_VelDenMapFramebuffer=VelDenMapFramebuffer;
	_SurfInkMapFramebuffer=SurfInkMapFramebuffer;
	_MiscMapFramebuffer=MiscMapFramebuffer;
	[VelDenMapFramebuffer lock];
	[SurfInkMapFramebuffer lock];
	[MiscMapFramebuffer lock];
	[self setInputSize:VelDenMapFramebuffer.size atIndex:0];
}

- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"InkSupply" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
	_VelDenMapUniform=[filterProgram uniformIndex:@"VelDenMap"];
	_SurfInkMapUniform=[filterProgram uniformIndex:@"SurfInkMap"];
	_MiscMapUniform=[filterProgram uniformIndex:@"MiscMap"];

    return self;
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
	glBindTexture(GL_TEXTURE_2D, [_VelDenMapFramebuffer texture]);
	glUniform1i(_VelDenMapUniform, 2);	
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [_SurfInkMapFramebuffer texture]);
    glUniform1i(_SurfInkMapUniform, 3);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [_MiscMapFramebuffer texture]);
    glUniform1i(_MiscMapUniform, 4);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    GLenum err = glGetError();
    if (err != GL_NO_ERROR) {
        NSLog(@"%s glerr %zd ",__PRETTY_FUNCTION__,err);
    }

    [_VelDenMapFramebuffer unlock];
	[_SurfInkMapFramebuffer unlock];
	[_MiscMapFramebuffer unlock];
}

@end

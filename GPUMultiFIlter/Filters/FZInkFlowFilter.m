//
//  FZInkFlowFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZInkFlowFilter.h"

@implementation FZInkFlowFilter
{
	GLuint _VelDenMapUniform;
	GLuint _MiscMapUniform;
	GLuint _Dist1MapUniform;
	GLuint _Dist2MapUniform;
	GLuint _FlowInkMapUniform;
	GLuint _SurfInkMapUniform;

	GLuint _Blk_aUniform;
	GLuint _offsetUniform;

	GPUImageFramebuffer *_VelDenMapFramebuffer;
	GPUImageFramebuffer *_MiscMapFramebuffer;
	GPUImageFramebuffer *_Dist1MapFramebuffer;
	GPUImageFramebuffer *_Dist2MapFramebuffer;
	GPUImageFramebuffer *_FlowInkMapFramebuffer;
	GPUImageFramebuffer *_SurfInkMapFramebuffer;
}

- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"Block" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    _VelDenMapUniform=[filterProgram uniformIndex:@"VelDenMap"];
	_MiscMapUniform=[filterProgram uniformIndex:@"MiscMap"];
	_Dist1MapUniform=[filterProgram uniformIndex:@"Dist1Map"];
	_Dist2MapUniform=[filterProgram uniformIndex:@"Dist2Map"];
	_FlowInkMapUniform=[filterProgram uniformIndex:@"FlowInkMap"];
	_SurfInkMapUniform=[filterProgram uniformIndex:@"SurfInkMap"];
	_Blk_aUniform=[filterProgram uniformIndex:@"Blk_a"];
	_offsetUniform=[filterProgram uniformIndex:@"offset"];

    return self;
}

- (void)setVelDenMap:(GPUImageFramebuffer *)VelDenMapFramebuffer miscMap:(GPUImageFramebuffer *)MiscMapFramebuffer dist1Map:(GPUImageFramebuffer *)Dist1MapFramebuffer dist2Map:(GPUImageFramebuffer *)Dist2MapFramebuffer flowInkMap:(GPUImageFramebuffer *)FlowInkMapFramebuffer surfInkMap:(GPUImageFramebuffer *)SurfInkMapFramebuffer
{
	_VelDenMapFramebuffer=VelDenMapFramebuffer;
	_MiscMapFramebuffer=MiscMapFramebuffer;
	_Dist1MapFramebuffer=Dist1MapFramebuffer;
	_Dist2MapFramebuffer=Dist2MapFramebuffer;
	_FlowInkMapFramebuffer=FlowInkMapFramebuffer;
	_SurfInkMapFramebuffer=SurfInkMapFramebuffer;

	[_VelDenMapFramebuffer lock];
	[_MiscMapFramebuffer lock];
	[_Dist1MapFramebuffer lock];
	[_Dist2MapFramebuffer lock];
	[_FlowInkMapFramebuffer lock];
	[_SurfInkMapFramebuffer lock];

	[self setInputSize:VelDenMapFramebuffer.size atIndex:0];
}

- (void)setOffset:(CGSize)newValue
{
	_offset=newValue;
    [self setSize:newValue forUniform:_offsetUniform program:filterProgram];
}

- (void)setBlk_aComp0:(CGFloat)comp0 comp1:(CGFloat)comp1
{
    CGSize Blk_a = CGSizeMake(comp0, comp1);
    [self setSize:Blk_a forUniform:_Blk_aUniform program:filterProgram];
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
    glBindTexture(GL_TEXTURE_2D, [_MiscMapFramebuffer texture]);
    glUniform1i(_MiscMapUniform, 3);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [_Dist1MapFramebuffer texture]);
    glUniform1i(_Dist1MapUniform, 4);

    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, [_Dist2MapFramebuffer texture]);
    glUniform1i(_Dist2MapUniform, 5);

    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, [_FlowInkMapFramebuffer texture]);
    glUniform1i(_FlowInkMapUniform, 6);

    glActiveTexture(GL_TEXTURE7);
    glBindTexture(GL_TEXTURE_2D, [_SurfInkMapFramebuffer texture]);
    glUniform1i(_SurfInkMapUniform, 7);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [_VelDenMapFramebuffer unlock];
	[_MiscMapFramebuffer unlock];
	[_Dist1MapFramebuffer unlock];
	[_Dist2MapFramebuffer unlock];
	[_FlowInkMapFramebuffer unlock];
	[_SurfInkMapFramebuffer unlock];
}
@end

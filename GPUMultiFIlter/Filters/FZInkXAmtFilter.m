//
//  FZInkXAmtFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZInkXAmtFilter.h"

@implementation FZInkXAmtFilter
{
	GLuint _VelDenMapUniform;
	GLuint _MiscMapUniform;
	GLuint _FlowInkMapUniform;
	GLuint _FixInkMapUniform;

	GLuint _FixRateUniform;

	GPUImageFramebuffer *_VelDenMapFramebuffer;
	GPUImageFramebuffer *_MiscMapFramebuffer;
	GPUImageFramebuffer *_FlowInkMapFramebuffer;
	GPUImageFramebuffer *_FixInkMapFramebuffer;
}

- (void)setFixRateComp0:(CGFloat)comp0 comp1:(CGFloat)comp1 comp2:(CGFloat)comp2
{
	GPUVector3 FixRate = {comp0, comp1, comp2};    
    [self setVec3:FixRate forUniform:_FixRateUniform program:filterProgram];
}

- (void)setVelDenMapFramebuffer:(GPUImageFramebuffer *)VelDenMapFramebuffer miscMapFramebuffer:(GPUImageFramebuffer *)MiscMapFramebuffer flowInkMapFramebuffer:(GPUImageFramebuffer *)FlowInkMapFramebuffer fixInkMapFramebuffer:(GPUImageFramebuffer *)FixInkMapFramebuffer
{
	_VelDenMapFramebuffer=VelDenMapFramebuffer;
	_MiscMapFramebuffer=MiscMapFramebuffer;
	_FlowInkMapFramebuffer=FlowInkMapFramebuffer;
	_FixInkMapFramebuffer=FixInkMapFramebuffer;

	[_VelDenMapFramebuffer lock];
	[_MiscMapFramebuffer lock];
	[_FlowInkMapFramebuffer lock];
	[_FixInkMapFramebuffer lock];
	[self setInputSize:VelDenMapFramebuffer.size atIndex:0];
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
	_FlowInkMapUniform=[filterProgram uniformIndex:@"FlowInkMap"];
	_FixInkMapUniform=[filterProgram uniformIndex:@"FixInkMap"];
	_FixRateUniform=[filterProgram uniformIndex:@"FixRate"];

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
    glBindTexture(GL_TEXTURE_2D, [_MiscMapFramebuffer texture]);
    glUniform1i(_MiscMapUniform, 3);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [_FlowInkMapFramebuffer texture]);
    glUniform1i(_FlowInkMapUniform, 4);

    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, [_FixInkMapFramebuffer texture]);
    glUniform1i(_FixInkMapUniform, 5);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [_VelDenMapFramebuffer unlock];
	[_MiscMapFramebuffer unlock];
	[_FlowInkMapFramebuffer unlock];
	[_FixInkMapFramebuffer unlock];
}
@end

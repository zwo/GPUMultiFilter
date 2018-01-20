//
//  FZBlockFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZBlockFilter.h"

@implementation FZBlockFilter
{
	GLint _A0Uniform;
	GLint _advect_pUniform;
	GLint _toe_pUniform;
	GLint _OmegaUniform;
	GLint _Corn_mulUniform;
	GLint _offsetUniform;
	GLint _Blk_1Uniform;
	GLint _Blk_2Uniform;
	GLint _Pin_wUniform;

	GLint _MiscMapUniform;
	GLint _VelDenMapUniform;
	GLint _FlowInkMapUniform;
	GLint _FixInkMapUniform;
	GLint _DisorderMapUniform;

	GPUImageFramebuffer *_MiscMapFramebuffer;
	GPUImageFramebuffer *_VelDenMapFramebuffer;
	GPUImageFramebuffer *_FlowInkMapFramebuffer;
	GPUImageFramebuffer *_FixInkMapFramebuffer;
	GPUImageFramebuffer *_DisorderMapFramebuffer;
}

- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"Block" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    _A0Uniform=[filterProgram uniformIndex:@"A0"];
	_advect_pUniform=[filterProgram uniformIndex:@"advect_p"];
	_toe_pUniform=[filterProgram uniformIndex:@"toe_p"];
	_OmegaUniform=[filterProgram uniformIndex:@"Omega"];
	_Corn_mulUniform=[filterProgram uniformIndex:@"Corn_mul"];
	_offsetUniform=[filterProgram uniformIndex:@"offset"];
	_Blk_1Uniform=[filterProgram uniformIndex:@"Blk_1"];
	_Blk_2Uniform=[filterProgram uniformIndex:@"Blk_2"];
	_Pin_wUniform=[filterProgram uniformIndex:@"Pin_w"];

	_MiscMapUniform=[filterProgram uniformIndex:@"MiscMap"];
	_VelDenMapUniform=[filterProgram uniformIndex:@"VelDenMap"];
	_FlowInkMapUniform=[filterProgram uniformIndex:@"FlowInkMap"];
	_FixInkMapUniform=[filterProgram uniformIndex:@"FixInkMap"];
	_DisorderMapUniform=[filterProgram uniformIndex:@"DisorderMap"];

	[self setA0:0.4444444f];
	[self setCorn_mul:pow(2.0f, 0.5f)];
    return self;
}

- (void)setA0:(CGFloat)newValue
{
	_A0=newValue;
    [self setFloat:newValue forUniform:_A0Uniform program:filterProgram];
}

- (void)setAdvect_p:(CGFloat)newValue
{
	_advect_p=newValue;
    [self setFloat:newValue forUniform:_advect_pUniform program:filterProgram];
}

- (void)setToe_p:(CGFloat)newValue
{
	_toe_p=newValue;
    [self setFloat:newValue forUniform:_toe_pUniform program:filterProgram];
}

- (void)setOmega:(CGFloat)newValue
{
	_Omega=newValue;
    [self setFloat:newValue forUniform:_OmegaUniform program:filterProgram];
}

- (void)setCorn_mul:(CGFloat)newValue
{
	_Corn_mul=newValue;
    [self setFloat:newValue forUniform:_Corn_mulUniform program:filterProgram];
}

- (void)setOffset:(CGSize)newValue
{
	_offset=newValue;
    [self setSize:newValue forUniform:_offsetUniform program:filterProgram];
}

- (void)setMiscMapFramebuffer:(GPUImageFramebuffer *)MiscMapFramebuffer velDenMapFramebuffer:(GPUImageFramebuffer *)VelDenMapFramebuffer flowInkMapFramebuffer:(GPUImageFramebuffer *)FlowInkMapFramebuffer fixInkMapFramebuffer:(GPUImageFramebuffer *)FixInkMapFramebuffer disorderMapFramebuffer:(GPUImageFramebuffer *)DisorderMapFramebuffer
{
	_MiscMapFramebuffer=MiscMapFramebuffer;
	_VelDenMapFramebuffer=VelDenMapFramebuffer;
	_FlowInkMapFramebuffer=FlowInkMapFramebuffer;
	_FixInkMapFramebuffer=FixInkMapFramebuffer;
	_DisorderMapFramebuffer=DisorderMapFramebuffer;
	[_MiscMapFramebuffer lock];
	[_VelDenMapFramebuffer lock];
	[_FlowInkMapFramebuffer lock];
	[_FixInkMapFramebuffer lock];
	[_DisorderMapFramebuffer lock];
	[self setInputSize:MiscMapFramebuffer.size atIndex:0];
}

- (void)setBLK1comp0:(CGFloat)comp0 comp1:(CGFloat)comp1 comp2:(CGFloat)comp2
{
	GPUVector3 Blk_1 = {comp0, comp1, comp2};    
    [self setVec3:Blk_1 forUniform:_Blk_1Uniform program:filterProgram];
}

- (void)setPin_Wcomp0:(CGFloat)comp0 comp1:(CGFloat)comp1 comp2:(CGFloat)comp2;
{
	GPUVector3 Pin_w = {comp0, comp1, comp2};    
    [self setVec3:Pin_w forUniform:_Pin_wUniform program:filterProgram];
}

- (void)setBLK2comp0:(CGFloat)comp0 comp1:(CGFloat)comp1
{
	GPUVector2 Blk_2 = {comp0, comp1};    
    [self setVec2:Blk_2 forUniform:_Blk_2Uniform program:filterProgram];
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
	glBindTexture(GL_TEXTURE_2D, [_MiscMapFramebuffer texture]);
	glUniform1i(_MiscMapUniform, 2);	
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [_VelDenMapFramebuffer texture]);
    glUniform1i(_VelDenMapUniform, 3);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [_FlowInkMapFramebuffer texture]);
    glUniform1i(_FlowInkMapUniform, 4);

    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, [_FixInkMapFramebuffer texture]);
    glUniform1i(_FixInkMapUniform, 5);

    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, [_DisorderMapFramebuffer texture]);
    glUniform1i(_DisorderMapUniform, 6);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [_MiscMapFramebuffer unlock];
	[_VelDenMapFramebuffer unlock];
	[_FlowInkMapFramebuffer unlock];
	[_FixInkMapFramebuffer unlock];
	[_DisorderMapFramebuffer unlock];
}

@end

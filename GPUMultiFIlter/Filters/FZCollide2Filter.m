//
//  FZCollide2Filter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZCollide2Filter.h"

@implementation FZCollide2Filter
{
	GLint _AUniform;
	GLint _BUniform;
	GLint _CUniform;
	GLint _DUniform;
	GLint _advect_pUniform;
	GLint _OmegaUniform;
	GLint _VelDenMapUniform;
	GLint _Dist2MapUniform;
	GLint _InkMapUniform;
	GPUImageFramebuffer *_VelDenMapFramebuffer;
	GPUImageFramebuffer *_Dist2MapFramebuffer;
	GPUImageFramebuffer *_InkMapFramebuffer;
}

- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"Collide2" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    _AUniform=[filterProgram uniformIndex:@"A"];
	_BUniform=[filterProgram uniformIndex:@"B"];
	_CUniform=[filterProgram uniformIndex:@"C"];
	_DUniform=[filterProgram uniformIndex:@"D"];
	_advect_pUniform=[filterProgram uniformIndex:@"advect_p"];
	_OmegaUniform=[filterProgram uniformIndex:@"Omega"];

	_VelDenMapUniform=[filterProgram uniformIndex:@"VelDenMap"];
	_Dist2MapUniform=[filterProgram uniformIndex:@"Dist2Map"];
	_InkMapUniform=[filterProgram uniformIndex:@"InkMap"];

	[self setA:0.02777778f b:0.08333334f c:0.125f d:0.04166667f];

    return self;
}

- (void)setVelDenMapFramebuffer:(GPUImageFramebuffer *)VelDenMapFramebuffer dist2MapFramebuffer:(GPUImageFramebuffer *)Dist2MapFramebuffer inkMapFramebuffer:(GPUImageFramebuffer *)InkMapFramebuffer
{
	_VelDenMapFramebuffer=VelDenMapFramebuffer;
	_Dist1MapFramebuffer=Dist2MapFramebuffer;
	_InkMapFramebuffer=InkMapFramebuffer;
	[_VelDenMapFramebuffer lock];
	[_Dist2MapFramebuffer lock];
	[_InkMapFramebuffer lock];
	[self setInputSize:VelDenMapFramebuffer.size atIndex:0];
}

- (void)setAdvect_p:(CGFloat)newValue
{
	_advect_p=newValue;
    [self setFloat:newValue forUniform:_advect_pUniform program:filterProgram];
}

- (void)setOmega:(CGFloat)newValue
{
	_omega=newValue;
    [self setFloat:newValue forUniform:_OmegaUniform program:filterProgram];
}

- (void)setA:(CGFloat)A b:(CGFloat)B c:(CGFloat)C d:(CGFloat)D
{
	[self setFloat:A forUniform:_AUniform program:filterProgram];
	[self setFloat:B forUniform:_BUniform program:filterProgram];
	[self setFloat:C forUniform:_CUniform program:filterProgram];
	[self setFloat:D forUniform:_DUniform program:filterProgram];
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
    glBindTexture(GL_TEXTURE_2D, [_Dist2MapFramebuffer texture]);
    glUniform1i(_Dist2MapUniform, 3);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [_InkMapFramebuffer texture]);
    glUniform1i(_InkMapUniform, 4);   
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [_VelDenMapFramebuffer unlock];
	[_Dist2MapFramebuffer unlock];
	[_InkMapFramebuffer unlock];
}
@end

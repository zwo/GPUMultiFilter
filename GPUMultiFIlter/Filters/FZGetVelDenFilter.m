//
//  FZGetVelDenFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZGetVelDenFilter.h"

@implementation FZGetVelDenFilter
{
	GLuint _wf_mulUniform;
	GLuint _EvaporUniform;
	GLuint _MiscMapUniform;
	GLuint _Dist1MapUniform;
	GLuint _Dist2MapUniform;
	GLuint _VelDenMapUniform;

	GPUImageFramebuffer *_MiscMapFramebuffer;
	GPUImageFramebuffer *_Dist1MapFramebuffer;
	GPUImageFramebuffer *_Dist2MapFramebuffer;
	GPUImageFramebuffer *_VelDenMapFramebuffer;
}

- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"GetVelDen" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    _wf_mulUniform=[filterProgram uniformIndex:@"wf_mul"];
	_EvaporUniform=[filterProgram uniformIndex:@"Evapor"];
	_MiscMapUniform=[filterProgram uniformIndex:@"MiscMap"];
	_Dist1MapUniform=[filterProgram uniformIndex:@"Dist1Map"];
	_Dist2MapUniform=[filterProgram uniformIndex:@"Dist2Map"];
	_VelDenMapUniform=[filterProgram uniformIndex:@"VelDenMap"];

    return self;
}

- (void)setWf_MUl:(CGFloat)wf_mul evapor:(CGFloat)evapor
{
	[self setFloat:wf_mul forUniform:_wf_mulUniform program:filterProgram];
	[self setFloat:evapor forUniform:_EvaporUniform program:filterProgram];
}

- (void)setMiscMapFramebuffer:(GPUImageFramebuffer *)MiscMapFramebuffer dist1MapFramebuffer:(GPUImageFramebuffer *)Dist1MapFramebuffer dist2MapFramebuffer:(GPUImageFramebuffer *)Dist2MapFramebuffer velDenMapFramebuffer:(GPUImageFramebuffer *)VelDenMapFramebuffer
{
	_MiscMapFramebuffer=MiscMapFramebuffer;
	_Dist1MapFramebuffer=Dist1MapFramebuffer;
	_Dist2MapFramebuffer=Dist2MapFramebuffer;
	_VelDenMapFramebuffer=VelDenMapFramebuffer;
	[_MiscMapFramebuffer lock];
	[_Dist1MapFramebuffer lock];
	[_Dist2MapFramebuffer lock];
	[_VelDenMapFramebuffer lock];
	[self setInputSize:MiscMapFramebuffer.size atIndex:0];
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
    glBindTexture(GL_TEXTURE_2D, [_Dist1MapFramebuffer texture]);
    glUniform1i(_Dist1MapUniform, 3);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [_Dist2MapFramebuffer texture]);
    glUniform1i(_Dist2MapUniform, 4);

    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, [_VelDenMapFramebuffer texture]);
    glUniform1i(_VelDenMapUniform, 5);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [_MiscMapFramebuffer unlock];
	[_Dist1MapFramebuffer unlock];
	[_Dist2MapFramebuffer unlock];
	[_VelDenMapFramebuffer unlock];
}
@end

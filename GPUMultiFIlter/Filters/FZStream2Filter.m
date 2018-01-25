//
//  FZStream2Filter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZStream2Filter.h"

@implementation FZStream2Filter
{
	GLuint _MiscMapUniform;
	GLuint _Dist2MapUniform;

	GLuint _Evapor_bUniform;
	GLuint _offsetUniform;

	GPUImageFramebuffer *_MiscMapFramebuffer;
	GPUImageFramebuffer *_Dist2MapFramebuffer;
}

- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"Stream2" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    _MiscMapUniform=[filterProgram uniformIndex:@"MiscMap"];
	_Dist2MapUniform=[filterProgram uniformIndex:@"Dist2Map"];
	_Evapor_bUniform=[filterProgram uniformIndex:@"Evapor_b"];
	_offsetUniform=[filterProgram uniformIndex:@"offset"];
    return self;
}

- (void)setMiscMapFramebuffer:(GPUImageFramebuffer *)MiscMapFramebuffer dist2MapFramebuffer:(GPUImageFramebuffer *)Dist2MapFramebuffer
{
	_MiscMapFramebuffer=MiscMapFramebuffer;
	_Dist2MapFramebuffer=Dist2MapFramebuffer;
	[_MiscMapFramebuffer lock];
	[_Dist2MapFramebuffer lock];
	[self setInputSize:MiscMapFramebuffer.size atIndex:0];
}

- (void)setOffset:(CGSize)newValue
{
	_offset=newValue;
    [self setSize:newValue forUniform:_offsetUniform program:filterProgram];
}

- (void)setEvapor_b:(CGFloat)newValue
{
	_evapor_b=newValue;
    [self setFloat:newValue forUniform:_Evapor_bUniform program:filterProgram];
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
    glBindTexture(GL_TEXTURE_2D, [_Dist2MapFramebuffer texture]);
    glUniform1i(_Dist2MapUniform, 3);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [_MiscMapFramebuffer unlock];
	[_Dist2MapFramebuffer unlock];
}
@end

//
//  FZInkXToFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZInkXToFilter.h"

@implementation FZInkXToFilter
{
	GLuint _FixInkMapUniform;
	GLuint _SinkInkMapUniform;
	GLuint _velDenUniform;

	GLuint _bEvaporToDisapperUniform;

	GPUImageFramebuffer *_FixInkMapFramebuffer;
	GPUImageFramebuffer *_SinkInkMapFramebuffer;
	GPUImageFramebuffer *_velDenFramebuffer;
}

- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"InkXTo" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    _FixInkMapUniform=[filterProgram uniformIndex:@"FixInkMap"];
	_SinkInkMapUniform=[filterProgram uniformIndex:@"SinkInkMap"];
	_velDenUniform=[filterProgram uniformIndex:@"velDen"];
	_bEvaporToDisapperUniform=[filterProgram uniformIndex:@"bEvaporToDisapper"];

    return self;
}

- (void)setBEvaporToDisapper:(BOOL)newValue
{
	_bEvaporToDisapper=newValue;
	if (newValue)
	{
		[self setFloat:1.0 forUniform:_bEvaporToDisapperUniform program:filterProgram];
	}else{
		[self setFloat:0.0 forUniform:_bEvaporToDisapperUniform program:filterProgram];
	}    
}

- (void)setFixInkMapFramebuffer:(GPUImageFramebuffer *)FixInkMapFramebuffer sinkInkMapFramebuffer:(GPUImageFramebuffer *)SinkInkMapFramebuffer velDenFramebuffer:(GPUImageFramebuffer *)velDenFramebuffer
{
	_FixInkMapFramebuffer=FixInkMapFramebuffer;
	_SinkInkMapFramebuffer=SinkInkMapFramebuffer;
	_velDenFramebuffer=velDenFramebuffer;

	[_FixInkMapFramebuffer lock];
	[_SinkInkMapFramebuffer lock];
	[_velDenFramebuffer lock];

	[self setInputSize:FixInkMapFramebuffer.size atIndex:0];
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
	glBindTexture(GL_TEXTURE_2D, [_FixInkMapFramebuffer texture]);
	glUniform1i(_FixInkMapUniform, 2);	
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [_SinkInkMapFramebuffer texture]);
    glUniform1i(_SinkInkMapUniform, 3);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [_velDenFramebuffer texture]);
    glUniform1i(_velDenUniform, 4);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    GLenum err = glGetError();
    if (err != GL_NO_ERROR) {
        NSLog(@"%s glerr %zd ",__PRETTY_FUNCTION__,err);
    }

    [_FixInkMapFramebuffer unlock];
	[_SinkInkMapFramebuffer unlock];
	[_velDenFramebuffer unlock];
}
@end

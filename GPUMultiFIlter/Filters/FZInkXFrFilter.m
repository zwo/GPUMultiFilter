//
//  FZInkXFrFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZInkXFrFilter.h"

@implementation FZInkXFrFilter
{
	GLuint _FlowInkMapUniform;
	GLuint _SinkInkMapUniform;

	GPUImageFramebuffer *_FlowInkMapFramebuffer;
	GPUImageFramebuffer *_SinkInkMapFramebuffer;
}

- (instancetype)init
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"InkXFr" ofType:@"glsl"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    _FlowInkMapUniform=[filterProgram uniformIndex:@"FlowInkMap"];
	_SinkInkMapUniform=[filterProgram uniformIndex:@"SinkInkMap"];
    return self;
}

- (void)setFlowInkMapFramebuffer:(GPUImageFramebuffer *)FlowInkMapFramebuffer sinkInkMapFramebuffer:(GPUImageFramebuffer *)SinkInkMapFramebuffer
{
	_FlowInkMapFramebuffer=FlowInkMapFramebuffer;
	_SinkInkMapFramebuffer=SinkInkMapFramebuffer;

	[_FlowInkMapFramebuffer lock];
	[_SinkInkMapFramebuffer lock];

	[self setInputSize:FlowInkMapFramebuffer.size atIndex:0];
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
	glBindTexture(GL_TEXTURE_2D, [_FlowInkMapFramebuffer texture]);
	glUniform1i(_FlowInkMapUniform, 2);	
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [_SinkInkMapFramebuffer texture]);
    glUniform1i(_SinkInkMapUniform, 3);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    GLenum err = glGetError();
    if (err != GL_NO_ERROR) {
        NSLog(@"%s glerr %zd ",__PRETTY_FUNCTION__,err);
    }

    [_FlowInkMapFramebuffer unlock];
	[_SinkInkMapFramebuffer unlock];
}

@end

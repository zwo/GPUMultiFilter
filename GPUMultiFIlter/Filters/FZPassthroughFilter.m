//
//  FZPassthroughFilter.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/15.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZPassthroughFilter.h"

@interface FZPassthroughFilter ()
@property (strong, nonatomic) GLProgram *program;
@property (assign, nonatomic) GLint filterPositionAttribute;
@property (assign, nonatomic) GLint filterTextureCoordinateAttribute;
@property (assign, nonatomic) GLint filterInputTextureUniform;
@end

@implementation FZPassthroughFilter

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        self.program = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
        [self.program addAttribute:@"position"];
        [self.program addAttribute:@"inputTextureCoordinate"];
        if (![self.program link])
        {
            NSString *progLog = [self.program programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [self.program fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [self.program vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            self.program = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
        _filterPositionAttribute = [self.program attributeIndex:@"position"];
        _filterTextureCoordinateAttribute = [self.program attributeIndex:@"inputTextureCoordinate"];
        _filterInputTextureUniform = [self.program uniformIndex:@"inputImageTexture"];
    });
    return self;
}

+ (void)renderTextureFrom:(GPUImageFramebuffer *)fromFbo to:(GPUImageFramebuffer *)toFbo rotation:(GPUImageRotationMode)rotationMode
{
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    FZPassthroughFilter *filter=[FZPassthroughFilter sharedInstance];
    [GPUImageContext setActiveShaderProgram:filter.program];
    [toFbo activateFramebuffer];
    glEnableVertexAttribArray(filter.filterPositionAttribute);
    glEnableVertexAttribArray(filter.filterTextureCoordinateAttribute);
    
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [fromFbo texture]);
    
    glUniform1i(filter.filterInputTextureUniform, 2);
    
    glVertexAttribPointer(filter.filterPositionAttribute, 2, GL_FLOAT, 0, 0, imageVertices);
    glVertexAttribPointer(filter.filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [GPUImageFilter textureCoordinatesForRotation:rotationMode]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end

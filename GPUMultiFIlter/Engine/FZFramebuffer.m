//
//  FZFramebuffer.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/5.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZFramebuffer.h"
#import "TestDraw.h"
#import "FZPassthroughFilter.h"
@interface FZFramebuffer ()
@property (strong, nonatomic) GPUImageFramebuffer *inputFramebuffer;
@property (assign, nonatomic) GLuint framebufferForDrawing;
@property (assign, nonatomic) GLuint colorRenderbufferForDrawing;
@property (assign, nonatomic) CGSize drawingRenderbufferSize;
@property (assign, nonatomic) GPUImageRotationMode inputRotation;
@property (strong, nonatomic) NSMutableArray *targets;
@property (strong, nonatomic) NSMutableArray *targetTextureIndices;
@end

@implementation FZFramebuffer

- (instancetype)initWithSize:(CGSize)size textureOptions:(GPUTextureOptions)fboTextureOptions onlyTexture:(BOOL)onlyGenerateTexture
{
    if (!(self = [super init]))
    {
        return nil;
    }
    self.outputFramebuffer=[[GPUImageFramebuffer alloc] initWithSize:size textureOptions:fboTextureOptions onlyTexture:onlyGenerateTexture];
    [self.outputFramebuffer disableReferenceCounting];
    _texturePixelSize=size;
    _inputRotation=kGPUImageNoRotation;
    _targets=[NSMutableArray arrayWithCapacity:2];
    _targetTextureIndices=[NSMutableArray arrayWithCapacity:2];
    return self;
}

- (instancetype)initWithSize:(CGSize)size textureOptions:(GPUTextureOptions)fboTextureOptions
{
    if (!(self = [self initWithSize:size textureOptions:fboTextureOptions onlyTexture:NO])) {
        return nil;
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size
{
    GPUTextureOptions defaultTextureOptions;
    defaultTextureOptions.minFilter = GL_LINEAR;
    defaultTextureOptions.magFilter = GL_LINEAR;
    defaultTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.internalFormat = GL_RGBA;
    defaultTextureOptions.format = GL_BGRA;
    defaultTextureOptions.type = GL_UNSIGNED_BYTE;
    if (!(self = [self initWithSize:size textureOptions:defaultTextureOptions onlyTexture:NO])) {
        return nil;
    }
    return self;
}

- (void)createFramebufferWithSize:(CGSize)size
{
    [GPUImageContext useImageProcessingContext];
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    GLuint colorRenderbuffer;
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, size.width, size.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);        
        GLenum errCode;
        errCode = glGetError();
        NSLog(@"error code %x", errCode);
    }
    _framebufferForDrawing=framebuffer;
    _colorRenderbufferForDrawing=colorRenderbuffer;
    _drawingRenderbufferSize=size;
}

- (void)activateFramebuffer
{
    [self.outputFramebuffer activateFramebuffer];
}

- (void)feedFramebufferToFilter:(id<GPUImageInput>)filter
{
    NSInteger nextAvailableTextureIndex = [filter nextAvailableTextureIndex];
    [filter setCurrentlyReceivingMonochromeInput:NO];
    [filter setInputSize:self.texturePixelSize atIndex:nextAvailableTextureIndex];
    [filter setInputFramebuffer:self.outputFramebuffer atIndex:nextAvailableTextureIndex];
    [filter newFrameReadyAtTime:kCMTimeIndefinite atIndex:nextAvailableTextureIndex];
}

- (void)beginDrawingWithRenderbufferSize:(CGSize)size
{
    [self createFramebufferWithSize:size];
}

- (void)endDrawing
{
    //https://github.com/slembcke/CloudBomber/blob/15c85d8be773104fe6fc3acc05db748ecc1c9525/CloudBomber/ChipmunkGLRenderBufferSampler.m
    //NSMutableData *pixelData = [NSMutableData dataWithLength:stride*height];
    //[(NSMutableData *)self.pixelData mutableBytes]
    GLubyte *imageData = NULL;
    imageData = (GLubyte *) calloc(1, (int)_drawingRenderbufferSize.width * (int)_drawingRenderbufferSize.height * 4);
    glFlush();
    glReadPixels(0, 0, _drawingRenderbufferSize.width, _drawingRenderbufferSize.height, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    [GPUImageContext useImageProcessingContext];
    [_outputFramebuffer activateFramebuffer];
    glBindTexture(GL_TEXTURE_2D, [_outputFramebuffer texture]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)_texturePixelSize.width, (int)_texturePixelSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    glDeleteRenderbuffers(1, &_framebufferForDrawing);
    glDeleteRenderbuffers(1, &_colorRenderbufferForDrawing);
    GLenum errCode = glGetError();
    if (errCode!=GL_NO_ERROR) {
        NSLog(@"113 error code %x", errCode);
    }
//    free(imageData);
}

- (void)clearRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    [self.outputFramebuffer activateFramebuffer];
    glClearColor(red / 255., green / 255., blue / 255., alpha / 255.);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (void)clear
{
    [self clearRed:255 green:0 blue:255 alpha:1];
}

- (UIImage *)testEndDrawing
{
    GLubyte *imageData = NULL;
    imageData = (GLubyte *) calloc(1, (int)_drawingRenderbufferSize.width * (int)_drawingRenderbufferSize.height * 4);
    glReadPixels(0, 0, _drawingRenderbufferSize.width, _drawingRenderbufferSize.height, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    UIImage *image=[TestDraw imageWithBuffer:imageData ofSize:_drawingRenderbufferSize];
    glDeleteRenderbuffers(1, &_framebufferForDrawing);
    glDeleteRenderbuffers(1, &_colorRenderbufferForDrawing);
    free(imageData);
    return image;
}

- (void)addTarget:(id<GPUImageInput>)newTarget
{
    NSInteger nextAvailableTextureIndex = [newTarget nextAvailableTextureIndex];
    [self addTarget:newTarget atTextureLocation:nextAvailableTextureIndex];
}

- (void)addTarget:(id<GPUImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation
{
    if([_targets containsObject:newTarget])
    {
        return;
    }
    runSynchronouslyOnVideoProcessingQueue(^{
        [_targets addObject:newTarget];
        [_targetTextureIndices addObject:[NSNumber numberWithInteger:textureLocation]];
    });
}

- (void)removeTarget:(id<GPUImageInput>)targetToRemove;
{
    if(![_targets containsObject:targetToRemove])
    {
        return;
    }
    
    NSInteger indexOfObject = [_targets indexOfObject:targetToRemove];
    NSInteger textureIndexOfTarget = [[_targetTextureIndices objectAtIndex:indexOfObject] integerValue];
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [targetToRemove setInputSize:CGSizeZero atIndex:textureIndexOfTarget];
        [targetToRemove setInputRotation:kGPUImageNoRotation atIndex:textureIndexOfTarget];
        
        [_targetTextureIndices removeObjectAtIndex:indexOfObject];
        [_targets removeObject:targetToRemove];
        [targetToRemove endProcessing];
    });
}

- (void)removeAllTargets;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        for (id<GPUImageInput> targetToRemove in _targets)
        {
            NSInteger indexOfObject = [_targets indexOfObject:targetToRemove];
            NSInteger textureIndexOfTarget = [[_targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            [targetToRemove setInputSize:CGSizeZero atIndex:textureIndexOfTarget];
            [targetToRemove setInputRotation:kGPUImageNoRotation atIndex:textureIndexOfTarget];
        }
        [_targets removeAllObjects];
        [_targetTextureIndices removeAllObjects];
    });
}

- (void)informTargetsAboutNewFrameAtTime:(CMTime)frameTime
{
    for (id<GPUImageInput> currentTarget in _targets)
    {
        NSInteger nextAvailableTextureIndex = [currentTarget nextAvailableTextureIndex];
        [currentTarget setCurrentlyReceivingMonochromeInput:NO];
        [currentTarget setInputSize:self.texturePixelSize atIndex:nextAvailableTextureIndex];
        [currentTarget setInputFramebuffer:self.outputFramebuffer atIndex:nextAvailableTextureIndex];
        [currentTarget newFrameReadyAtTime:frameTime atIndex:nextAvailableTextureIndex];
    }
}
#pragma mark - GPUImageInput

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    //https://stackoverflow.com/questions/23981016/best-method-to-copy-texture-to-texture
    [FZPassthroughFilter renderTextureFrom:self.inputFramebuffer to:self.outputFramebuffer rotation:_inputRotation];
    [self.inputFramebuffer unlock];
    self.inputFramebuffer=nil;
    [self informTargetsAboutNewFrameAtTime:frameTime];
}

- (NSInteger)nextAvailableTextureIndex;
{
    return 0;
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    self.inputFramebuffer=newInputFramebuffer;
    [self.inputFramebuffer lock];
}

- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex;
{
    CGSize rotatedSize = sizeToRotate;
    
    if (GPUImageRotationSwapsWidthAndHeight(_inputRotation))
    {
        rotatedSize.width = sizeToRotate.height;
        rotatedSize.height = sizeToRotate.width;
    }
    
    return rotatedSize;
}

- (CGPoint)rotatedPoint:(CGPoint)pointToRotate forRotation:(GPUImageRotationMode)rotation;
{
    CGPoint rotatedPoint;
    switch(rotation)
    {
        case kGPUImageNoRotation: return pointToRotate; break;
        case kGPUImageFlipHorizonal:
        {
            rotatedPoint.x = 1.0 - pointToRotate.x;
            rotatedPoint.y = pointToRotate.y;
        }; break;
        case kGPUImageFlipVertical:
        {
            rotatedPoint.x = pointToRotate.x;
            rotatedPoint.y = 1.0 - pointToRotate.y;
        }; break;
        case kGPUImageRotateLeft:
        {
            rotatedPoint.x = 1.0 - pointToRotate.y;
            rotatedPoint.y = pointToRotate.x;
        }; break;
        case kGPUImageRotateRight:
        {
            rotatedPoint.x = pointToRotate.y;
            rotatedPoint.y = 1.0 - pointToRotate.x;
        }; break;
        case kGPUImageRotateRightFlipVertical:
        {
            rotatedPoint.x = pointToRotate.y;
            rotatedPoint.y = pointToRotate.x;
        }; break;
        case kGPUImageRotateRightFlipHorizontal:
        {
            rotatedPoint.x = 1.0 - pointToRotate.y;
            rotatedPoint.y = 1.0 - pointToRotate.x;
        }; break;
        case kGPUImageRotate180:
        {
            rotatedPoint.x = 1.0 - pointToRotate.x;
            rotatedPoint.y = 1.0 - pointToRotate.y;
        }; break;
    }
    
    return rotatedPoint;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    //
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    _inputRotation = newInputRotation;
}

- (void)forceProcessingAtSize:(CGSize)frameSize
{
    
}

- (void)forceProcessingAtSizeRespectingAspectRatio:(CGSize)frameSize
{
    
}

- (CGSize)maximumOutputSize
{
    return CGSizeZero;
}

- (void)endProcessing
{
    
}

- (BOOL)wantsMonochromeInput
{
    return NO;
}

- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue
{
    
}

- (BOOL)shouldIgnoreUpdatesToThisTarget
{
    return NO;
}

- (BOOL)enabled
{
    return YES;
}

@end

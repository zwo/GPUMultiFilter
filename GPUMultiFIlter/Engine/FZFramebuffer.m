//
//  FZFramebuffer.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/5.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZFramebuffer.h"
#import "TestDraw.h"
#import "FilterLine.h"
@interface FZFramebuffer ()
@property (strong, nonatomic) GPUImageFramebuffer *outputFramebuffer;
@property (assign, nonatomic) GLuint framebufferForDrawing;
@property (assign, nonatomic) GLuint colorRenderbufferForDrawing;
@property (assign, nonatomic) CGSize drawingRenderbufferSize;
@property (strong, nonatomic) GPUImagePicture *picture;
@end

@implementation FZFramebuffer

- (instancetype)initWithSize:(CGSize)size textureOptions:(GPUTextureOptions)fboTextureOptions onlyTexture:(BOOL)onlyGenerateTexture
{
    if (!(self = [super init]))
    {
        return nil;
    }
//    self.outputFramebuffer=[[GPUImageFramebuffer alloc] initWithSize:size textureOptions:fboTextureOptions onlyTexture:onlyGenerateTexture];
//    [self.outputFramebuffer disableReferenceCounting];
    _texturePixelSize=size;
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
//    NSInteger nextAvailableTextureIndex = [filter nextAvailableTextureIndex];
//    [filter setCurrentlyReceivingMonochromeInput:NO];
//    [filter setInputSize:self.texturePixelSize atIndex:nextAvailableTextureIndex];
//    [filter setInputFramebuffer:self.outputFramebuffer atIndex:nextAvailableTextureIndex];
//    [filter newFrameReadyAtTime:kCMTimeIndefinite atIndex:nextAvailableTextureIndex];
    FilterLine *line=[FilterLine new];
    [self.picture addTarget:line];
    [line addTarget:filter];
    [self.picture processImage];
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
    UIImage *image=[TestDraw imageWithBuffer:imageData ofSize:_drawingRenderbufferSize];
    self.picture=[[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES removePremultiplication:YES];
    glDeleteRenderbuffers(1, &_framebufferForDrawing);
    glDeleteRenderbuffers(1, &_colorRenderbufferForDrawing);
    GLenum errCode = glGetError();
    if (errCode!=GL_NO_ERROR) {
        NSLog(@"113 error code %x", errCode);
    }
//    free(imageData);
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

@end

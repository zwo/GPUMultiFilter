//
//  FZFramebuffer.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/5.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZFramebuffer.h"

@interface FZFramebuffer ()
@property (strong, nonatomic) GPUImageFramebuffer *outputFramebuffer;
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

- (void)dealloc
{
    [self.outputFramebuffer destroyFramebuffer];
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

@end

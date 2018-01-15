//
//  FZFramebufferPingPong.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/15.
//  Copyright © 2018年 周维鸥. All rights reserved.
//
#import "FZFramebufferPingPong.h"

@interface FZFramebufferPingPong ()
@property (assign, nonatomic) NSInteger readFboIndex;
@property (assign, nonatomic) NSInteger writeFboIndex;
@property (strong, nonatomic) NSArray<FZFramebuffer*> *fboArray;
@end

@implementation FZFramebufferPingPong

- (instancetype)initWithSize:(CGSize)size textureOptions:(GPUTextureOptions)fboTextureOptions onlyTexture:(BOOL)onlyGenerateTexture
{
    if (!(self = [super init]))
    {
        return nil;
    }
    FZFramebuffer *fbo1=[[FZFramebuffer alloc] initWithSize:size textureOptions:fboTextureOptions onlyTexture:onlyGenerateTexture];
    FZFramebuffer *fbo2=[[FZFramebuffer alloc] initWithSize:size textureOptions:fboTextureOptions onlyTexture:onlyGenerateTexture];
    self.fboArray=@[fbo1,fbo2];
    self.readFboIndex=0;
    self.writeFboIndex=1;
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

- (void)swap
{
    NSInteger temp=self.readFboIndex;
    self.readFboIndex=self.writeFboIndex;
    self.writeFboIndex=temp;
}

- (FZFramebuffer *)getOldFbo
{
    return [self getReadFbo];
}

- (FZFramebuffer *)getNewFbo
{
    return [self getWriteFbo];
}

- (FZFramebuffer *)getReadFbo
{
    return self.fboArray[self.readFboIndex];
}

- (FZFramebuffer *)getWriteFbo
{
    return self.fboArray[self.writeFboIndex];
}

- (void)clear
{
    for (FZFramebuffer *fbo in self.fboArray) {
        [fbo clear];
    }
}

@end

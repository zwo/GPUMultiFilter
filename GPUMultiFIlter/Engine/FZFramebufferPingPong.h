//
//  FZFramebufferPingPong.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/15.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZFramebuffer.h"
@interface FZFramebufferPingPong : NSObject
- (instancetype)initWithSize:(CGSize)size;
- (instancetype)initWithSize:(CGSize)size textureOptions:(GPUTextureOptions)fboTextureOptions;
- (instancetype)initWithSize:(CGSize)size textureOptions:(GPUTextureOptions)fboTextureOptions onlyTexture:(BOOL)onlyGenerateTexture;
- (void)swap;
- (FZFramebuffer *)getOldFbo;
- (FZFramebuffer *)getNewFbo;
- (FZFramebuffer *)getReadFbo;
- (FZFramebuffer *)getWriteFbo;
- (void)clear;
@end

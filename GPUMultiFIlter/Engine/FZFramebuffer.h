//
//  FZFramebuffer.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/5.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
@interface FZFramebuffer : NSObject
@property (assign, nonatomic, readonly) CGSize texturePixelSize;
- (instancetype)initWithSize:(CGSize)size;
- (instancetype)initWithSize:(CGSize)size textureOptions:(GPUTextureOptions)fboTextureOptions;
- (instancetype)initWithSize:(CGSize)size textureOptions:(GPUTextureOptions)fboTextureOptions onlyTexture:(BOOL)onlyGenerateTexture;
- (void)activateFramebuffer;
- (void)feedFramebufferToFilter:(id<GPUImageInput>)filter;
- (void)beginDrawingWithRenderbufferSize:(CGSize)size;
- (void)endDrawing;
- (void)clear;
- (void)clearRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (UIImage *)testEndDrawing;
@end

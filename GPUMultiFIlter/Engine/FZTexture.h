//
//  FZTexture.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/3.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZTexture : NSObject
@property (strong, nonatomic) GPUImageFramebuffer *outputFramebuffer;
@property (assign, nonatomic, readonly) CGSize texturePixelSize;
- (instancetype)initWithImage:(UIImage *)image;
- (void)processTextureToFilter:(id<GPUImageInput>)filter;
@end

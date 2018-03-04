//
//  FZXYZ4OutputDebugFilter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/3/4.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZXYZ4OutputDebugFilter : GPUImageFilter
@property(strong, nonatomic) GPUImageFramebuffer *renderFramebuffer;
- (void)begin;
- (void)end;
- (void)renderFramebuffer:(GPUImageFramebuffer *)framebuffer toGuadrant:(NSInteger)index;
@end

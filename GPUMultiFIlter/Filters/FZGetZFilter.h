//
//  FZGetZFilter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZGetZFilter : GPUImageFilter
@property(strong, nonatomic) GPUImageFramebuffer *renderFramebuffer;
- (void)setSourceFramebuffer:(GPUImageFramebuffer *)framebuffer;
@end

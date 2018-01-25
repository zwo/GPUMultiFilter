//
//  FZInkFlowFilter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZInkFlowFilter : GPUImageFilter
@property(readwrite, nonatomic) CGSize offset;
@property(strong, nonatomic) GPUImageFramebuffer *renderFramebuffer;
- (void)setBlk_aComp0:(CGFloat)comp0 comp1:(CGFloat)comp1;
- (void)setVelDenMap:(GPUImageFramebuffer *)VelDenMapFramebuffer miscMap:(GPUImageFramebuffer *)MiscMapFramebuffer dist1Map:(GPUImageFramebuffer *)Dist1MapFramebuffer dist2Map:(GPUImageFramebuffer *)Dist2MapFramebuffer flowInkMap:(GPUImageFramebuffer *)FlowInkMapFramebuffer surfInkMap:(GPUImageFramebuffer *)SurfInkMapFramebuffer;
@end

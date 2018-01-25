//
//  FZGetVelDenFilter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZGetVelDenFilter : GPUImageFilter
@property(strong, nonatomic) GPUImageFramebuffer *renderFramebuffer;
- (void)setWf_MUl:(CGFloat)wf_mul evapor:(CGFloat)evapor;

- (void)setMiscMapFramebuffer:(GPUImageFramebuffer *)MiscMapFramebuffer dist1MapFramebuffer:(GPUImageFramebuffer *)Dist1MapFramebuffer dist2MapFramebuffer:(GPUImageFramebuffer *)Dist2MapFramebuffer velDenMapFramebuffer:(GPUImageFramebuffer *)VelDenMapFramebuffer;

@end

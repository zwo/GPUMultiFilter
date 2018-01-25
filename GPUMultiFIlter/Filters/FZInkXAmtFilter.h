//
//  FZInkXAmtFilter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZInkXAmtFilter : GPUImageFilter
@property(strong, nonatomic) GPUImageFramebuffer *renderFramebuffer;
- (void)setFixRateComp0:(CGFloat)comp0 comp1:(CGFloat)comp1 comp2:(CGFloat)comp2;
- (void)setVelDenMapFramebuffer:(GPUImageFramebuffer *)VelDenMapFramebuffer miscMapFramebuffer:(GPUImageFramebuffer *)MiscMapFramebuffer flowInkMapFramebuffer:(GPUImageFramebuffer *)FlowInkMapFramebuffer fixInkMapFramebuffer:(GPUImageFramebuffer *)FixInkMapFramebuffer;
@end

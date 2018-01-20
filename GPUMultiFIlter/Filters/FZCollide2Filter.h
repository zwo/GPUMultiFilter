//
//  FZCollide2Filter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZCollide2Filter : GPUImageFilter
@property(readwrite, nonatomic) CGFloat advect_p;
@property(readwrite, nonatomic) CGFloat omega;
@property(strong, nonatomic) GPUImageFramebuffer *renderFramebuffer;
- (void)setA:(CGFloat)A b:(CGFloat)B c:(CGFloat)C d:(CGFloat)D;
- (void)setVelDenMapFramebuffer:(GPUImageFramebuffer *)VelDenMapFramebuffer dist2MapFramebuffer:(GPUImageFramebuffer *)Dist2MapFramebuffer inkMapFramebuffer:(GPUImageFramebuffer *)InkMapFramebuffer;
@end

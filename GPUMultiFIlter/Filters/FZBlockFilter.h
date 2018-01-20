//
//  FZBlockFilter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZBlockFilter : GPUImageFilter
@property(readwrite, nonatomic) CGFloat A0;
@property(readwrite, nonatomic) CGFloat advect_p;
@property(readwrite, nonatomic) CGFloat toe_p;
@property(readwrite, nonatomic) CGFloat Omega;
@property(readwrite, nonatomic) CGFloat Corn_mul;
@property(readwrite, nonatomic) CGSize offset;
@property(strong, nonatomic) GPUImageFramebuffer *renderFramebuffer;
- (void)setMiscMapFramebuffer:(GPUImageFramebuffer *)MiscMapFramebuffer velDenMapFramebuffer:(GPUImageFramebuffer *)VelDenMapFramebuffer flowInkMapFramebuffer:(GPUImageFramebuffer *)FlowInkMapFramebuffer fixInkMapFramebuffer:(GPUImageFramebuffer *)FixInkMapFramebuffer disorderMapFramebuffer:(GPUImageFramebuffer *)DisorderMapFramebuffer;
- (void)setBLK1comp0:(CGFloat)comp0 comp1:(CGFloat)comp1 comp2:(CGFloat)comp2;
- (void)setPin_Wcomp0:(CGFloat)comp0 comp1:(CGFloat)comp1 comp2:(CGFloat)comp2;
- (void)setBLK2comp0:(CGFloat)comp0 comp1:(CGFloat)comp1;
@end

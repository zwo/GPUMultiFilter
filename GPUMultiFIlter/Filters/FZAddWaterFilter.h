//
//  FZAddWaterFilter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZAddWaterFilter : GPUImageFilter
@property(readwrite, nonatomic) CGFloat gamma;
@property(readwrite, nonatomic) CGFloat baseMask;
@property(readwrite, nonatomic) CGFloat waterAmount;

- (void)setMiscFramebuffer:(GPUImageFramebuffer *)miscFramebuffer waterSurfaceFramebuffer:(GPUImageFramebuffer *)waterSurfaceFramebuffer;

@end

//
//  FZPlayFilter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/3/8.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZPlayFilter : GPUImageFilter
@property(strong, nonatomic) GPUImageFramebuffer *renderFramebuffer;
@property (assign, nonatomic) CGFloat pos;
- (void)setWaterSurfaceFramebuffer:(GPUImageFramebuffer *)waterSurfaceFramebuffer;
@end

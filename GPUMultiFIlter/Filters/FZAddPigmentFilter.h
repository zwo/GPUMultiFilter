//
//  FZAddPigmentFilter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/12.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZAddPigmentFilter : GPUImageFilter
@property(readwrite, nonatomic) CGFloat gamma;
@property(readwrite, nonatomic) CGFloat baseMask;
@property(strong, nonatomic) GPUImageFramebuffer *renderFramebuffer;
- (void)setSurfInkFramebuffer:(GPUImageFramebuffer *)surfInkFramebuffer waterSurfaceFramebuffer:(GPUImageFramebuffer *)waterSurfaceFramebuffer miscFramebuffer:(GPUImageFramebuffer *)miscFramebuffer;
@end

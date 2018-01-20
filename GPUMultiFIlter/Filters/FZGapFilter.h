//
//  FZGapFilter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZGapFilter : GPUImageFilter
- (void)set GrainFramebuffer:(GPUImageFramebuffer *)GrainFramebuffer alumFramebuffer:(GPUImageFramebuffer *)AlumFramebuffer pinningFramebuffer:(GPUImageFramebuffer *)PinningFramebuffer;
@end

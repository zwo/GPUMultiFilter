//
//  FZStream1Filter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZStream1Filter : GPUImageFilter
@property(readwrite, nonatomic) CGSize offset;
@property(readwrite, nonatomic) CGFloat evapor_b;
@property(strong, nonatomic) GPUImageFramebuffer *renderFramebuffer;
- (void)setMiscMapFramebuffer:(GPUImageFramebuffer *)MiscMapFramebuffer dist1MapFramebuffer:(GPUImageFramebuffer *)Dist1MapFramebuffer;
@end

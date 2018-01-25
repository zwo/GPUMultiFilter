//
//  FZInkXToFilter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/19.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FZInkXToFilter : GPUImageFilter
@property(readwrite, nonatomic) BOOL bEvaporToDisapper;
@property(strong, nonatomic) GPUImageFramebuffer *renderFramebuffer;
- (void)setFixInkMapFramebuffer:(GPUImageFramebuffer *)FixInkMapFramebuffer sinkInkMapFramebuffer:(GPUImageFramebuffer *)SinkInkMapFramebuffer velDenFramebuffer:(GPUImageFramebuffer *)velDenFramebuffer;

@end

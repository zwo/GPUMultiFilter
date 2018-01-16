//
//  FZPassthroughFilter.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/15.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>
@interface FZPassthroughFilter : NSObject

+ (instancetype)sharedInstance;
+ (void)renderTextureFrom:(GPUImageFramebuffer *)fromFbo to:(GPUImageFramebuffer *)toFbo rotation:(GPUImageRotationMode)rotationMode;

@end

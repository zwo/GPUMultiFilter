//
//  FZInkSim.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/2.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>
typedef struct fzuniformInfos
{
    float brushsize;
    float baseMask;
    float gamma;
    float omega;
    float advect_p;
    float evapor_b;
    float evapor;
    float b11;
    float b12;
    float b13;
    float b21;
    float b22;
    float p1;
    float p2;
    float p3;
    float ba1;
    float ba2;
    float f1;
    float f2;
    float f3;
    float toe_p;
    float waterAmount;
    float wf_mul;
}FZUniformInfos;

typedef NS_ENUM(NSUInteger, FZDrawMode) {
    FZDrawModeInkFix,
    FZDrawModeInkSurf,
    FZDrawModeInkFlow,
    FZDrawModeInkWaterFlow
};

@interface FZInkSim : NSObject
@property (assign, nonatomic) FZUniformInfos uniformInfos;
@property (assign, nonatomic) FZDrawMode drawMode;
@end

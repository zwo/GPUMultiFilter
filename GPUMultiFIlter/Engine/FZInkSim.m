//
//  FZInkSim.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/2.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZInkSim.h"

@implementation FZInkSim

- (instancetype)init
{
    self=[super init];
    if (self) {
        restoreToSystemDefaults(self.uniformInfos);
        self.drawMode=FZDrawModeInkFix;
    }
    return self;
}

void restoreToSystemDefaults(FZUniformInfos infos)
{
    infos.brushsize = 7.086956501;
    infos.baseMask = 0.037267081;
    infos.gamma = 0.037267081;
    infos.omega = 0.968944073;
    infos.advect_p = 0.100000001;
    infos.evapor_b = 0.000010000;
    infos.evapor = 0.000500000;
    infos.b11 = 0.009316770;
    infos.b12 = 0.391304344;
    infos.b13 = 0.009316770;
    infos.b21 = 0.123152710;
    infos.b22 = 0.307453424;
    infos.p1 = 0.000000000;
    infos.p2 = 0.300000012;
    infos.p3 = 0.200000003;
    infos.ba1 = 0.000040994;
    infos.ba2 = 0.000043168;
    infos.f1 = 0.010000000;
    infos.f2 = 0.090000004;
    infos.f3 = 0.090000004;
    infos.toe_p = 0.100000001;
    infos.waterAmount = 1.000000000;
    infos.wf_mul = 1.0f;
}

@end

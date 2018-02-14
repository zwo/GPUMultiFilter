//
//  FZInkSim.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/2.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZInkSim.h"
#import "FZGapFilter.h"
#import "FZAddPigmentFilter.h"
#import "FZAddWaterFilter.h"
#import "FZBlockFilter.h"
#import "FZCollide1Filter.h"
#import "FZCollide2Filter.h"
#import "FZStream1Filter.h"
#import "FZStream2Filter.h"
#import "FZGetVelDenFilter.h"
#import "FZInkSupplyFilter.h"
#import "FZInkXAmtFilter.h"
#import "FZInkXToFilter.h"
#import "FZInkXFrFilter.h"
#import "FZInkFlowFilter.h"
#import "FZGetXYZFilter.h"
#import "FZGetZFilter.h"

@interface FZInkSim ()
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) FZTexture *grainTexture;
@property (strong, nonatomic) FZTexture *alumTexture;
@property (strong, nonatomic) FZTexture *pinningTexture;

@property (strong, nonatomic) FZFramebuffer *fboDepositionBuffer;
@property (strong, nonatomic) FZFramebuffer *fboDisorder;

@property (strong, nonatomic) FZFramebufferPingPong *miscPP;
@property (strong, nonatomic) FZFramebufferPingPong *velDenPP;
@property (strong, nonatomic) FZFramebufferPingPong *dist1PP;
@property (strong, nonatomic) FZFramebufferPingPong *dist2PP;
@property (strong, nonatomic) FZFramebufferPingPong *surfInkPP;
@property (strong, nonatomic) FZFramebufferPingPong *flowInkPP;
@property (strong, nonatomic) FZFramebufferPingPong *fixInkPP;
@property (strong, nonatomic) FZFramebufferPingPong *sinkInkPP;

@property (strong, nonatomic) FZGapFilter *gapFilter;
@property (strong, nonatomic) FZAddPigmentFilter *addPigmentFilter;
@property (strong, nonatomic) FZAddWaterFilter *addWaterFilter;
@property (strong, nonatomic) FZBlockFilter *blockFilter;
@property (strong, nonatomic) FZCollide1Filter *collide1Filter;
@property (strong, nonatomic) FZCollide2Filter *collide2Filter;
@property (strong, nonatomic) FZStream1Filter *stream1Filter;
@property (strong, nonatomic) FZStream2Filter *stream2Filter;
@property (strong, nonatomic) FZGetVelDenFilter *getVelDenFilter;
@property (strong, nonatomic) FZInkSupplyFilter *inkSupplyFilter;
@property (strong, nonatomic) FZInkXAmtFilter *inkXAmtFilter;
@property (strong, nonatomic) FZInkXToFilter *inkXToFilter;
@property (strong, nonatomic) FZInkXFrFilter *inkXFrFilter;
@property (strong, nonatomic) FZInkFlowFilter *inkFlowFilter;
@property (strong, nonatomic) FZGetXYZFilter *getXYZFilter;
@property (strong, nonatomic) FZGetZFilter *getZFilter;
@end

@implementation FZInkSim

- (instancetype)initWithRenderView:(GPUImageView *)renderView
{
    self=[super init];
    if (self) {
        restoreToSystemDefaults(self.uniformInfos);
        self.drawMode=FZDrawModeInkFix;
        self.renderView=renderView;
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

- (void)setupWithSize:(CGSize)size
{
    if (CGSizeEqualToSize(size, self.size)) {
        return;
    }
    self.size=size;
    _grainTexture=[[FZTexture alloc] initWithImage:[UIImage imageNamed:@"grain.jpg"]];
    _alumTexture=[[FZTexture alloc] initWithImage:[UIImage imageNamed:@"alum3"]];
    _pinningTexture=[[FZTexture alloc] initWithImage:[UIImage imageNamed:@"pinning"]];
    
    self.gapFilter=[[FZGapFilter alloc] init];
    self.addPigmentFilter=[[FZAddPigmentFilter alloc] init];
    self.addWaterFilter=[[FZAddWaterFilter alloc] init];
    self.blockFilter=[[FZBlockFilter alloc] init];
    self.collide1Filter=[[FZCollide1Filter alloc] init];
    self.collide2Filter=[[FZCollide2Filter alloc] init];
    self.stream1Filter=[[FZStream1Filter alloc] init];
    self.stream2Filter=[[FZStream2Filter alloc] init];
    self.getVelDenFilter=[[FZGetVelDenFilter alloc] init];
    self.inkSupplyFilter=[[FZInkSupplyFilter alloc] init];
    self.inkXAmtFilter=[[FZInkXAmtFilter alloc] init];
    self.inkXToFilter=[[FZInkXToFilter alloc] init];
    self.inkXFrFilter=[[FZInkXFrFilter alloc] init];
    self.inkFlowFilter=[[FZInkFlowFilter alloc] init];
    self.getXYZFilter=[[FZGetXYZFilter alloc] init];
    self.getZFilter=[[FZGetZFilter alloc] init];
    
    self.fboDepositionBuffer=[[FZFramebuffer alloc] initWithSize:size];
    self.fboDisorder=[[FZFramebuffer alloc] initWithSize:size];
    
    self.miscPP=[[FZFramebufferPingPong alloc] initWithSize:size];
    self.velDenPP=[[FZFramebufferPingPong alloc] initWithSize:size];
    self.dist1PP=[[FZFramebufferPingPong alloc] initWithSize:size];
    self.dist2PP=[[FZFramebufferPingPong alloc] initWithSize:size];
    self.surfInkPP=[[FZFramebufferPingPong alloc] initWithSize:size];
    self.flowInkPP=[[FZFramebufferPingPong alloc] initWithSize:size];
    self.fixInkPP=[[FZFramebufferPingPong alloc] initWithSize:size];
    self.sinkInkPP=[[FZFramebufferPingPong alloc] initWithSize:size];
    
    [self.fboDepositionBuffer clear];
    [self.fboDisorder clear];
    
    [self fillDisorderBuffer];
}

- (void)fillDisorderBuffer
{
    self.gapFilter.renderFramebuffer=self.fboDisorder.outputFramebuffer;
    [self.gapFilter setGrainFramebuffer:_grainTexture.outputFramebuffer alumFramebuffer:_alumTexture.outputFramebuffer pinningFramebuffer:_pinningTexture.outputFramebuffer];
    [self.gapFilter newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
}

- (void)update
{
    runAsynchronouslyOnVideoProcessingQueue(^{
        glDisable(GL_BLEND);
        FZUniformInfos uniforms=self.uniformInfos;
        
        self.blockFilter.renderFramebuffer=[self.miscPP getNewFbo].outputFramebuffer;
        self.blockFilter.advect_p=uniforms.advect_p;
        self.blockFilter.toe_p=uniforms.toe_p;
        self.blockFilter.Omega=uniforms.omega;
        self.blockFilter.offset=CGSizeMake(1/self.size.width, 1/self.size.height);
        [self.blockFilter setBLK1comp0:uniforms.b11 comp1:uniforms.b12 comp2:uniforms.b13];
        [self.blockFilter setBLK2comp0:uniforms.b21 comp1:uniforms.b22];
        [self.blockFilter setPin_Wcomp0:uniforms.p1 comp1:uniforms.p2 comp2:uniforms.p3];
        [self.blockFilter setMiscMapFramebuffer:self.miscPP.getOldFbo.outputFramebuffer velDenMapFramebuffer:self.velDenPP.getOldFbo.outputFramebuffer flowInkMapFramebuffer:self.flowInkPP.getOldFbo.outputFramebuffer fixInkMapFramebuffer:self.fixInkPP.getOldFbo.outputFramebuffer disorderMapFramebuffer:self.fboDisorder.outputFramebuffer];
        [self.blockFilter newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        [self.miscPP swap];
        
        self.collide1Filter.renderFramebuffer=[self.dist1PP getNewFbo].outputFramebuffer;
        self.collide1Filter.advect_p=uniforms.advect_p;
        self.collide1Filter.omega=uniforms.omega;
        [self.collide1Filter setVelDenMapFramebuffer:self.velDenPP.getOldFbo.outputFramebuffer dist1MapFramebuffer:self.dist1PP.getOldFbo.outputFramebuffer inkMapFramebuffer:self.flowInkPP.getOldFbo.outputFramebuffer];
        [self.collide1Filter newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        [self.dist1PP swap];
        
        self.collide2Filter.renderFramebuffer=[self.dist2PP getNewFbo].outputFramebuffer;
        self.collide2Filter.advect_p=uniforms.advect_p;
        self.collide2Filter.omega=uniforms.omega;
        [self.collide2Filter setVelDenMapFramebuffer:self.velDenPP.getOldFbo.outputFramebuffer dist2MapFramebuffer:self.dist2PP.getOldFbo.outputFramebuffer inkMapFramebuffer:self.flowInkPP.getOldFbo.outputFramebuffer];
        [self.collide2Filter newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        [self.dist2PP swap];
        
        self.stream1Filter.renderFramebuffer=[self.dist1PP getNewFbo].outputFramebuffer;
        self.stream1Filter.evapor_b=uniforms.evapor_b;
        self.stream1Filter.offset=CGSizeMake(1/self.size.width, 1/self.size.height);
        [self.stream1Filter setMiscMapFramebuffer:self.miscPP.getOldFbo.outputFramebuffer dist1MapFramebuffer:self.dist1PP.getOldFbo.outputFramebuffer];
        [self.stream1Filter newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        [self.dist1PP swap];
        
        self.stream2Filter.renderFramebuffer=[self.dist2PP getNewFbo].outputFramebuffer;
        self.stream2Filter.evapor_b=uniforms.evapor_b;
        self.stream2Filter.offset=CGSizeMake(1/self.size.width, 1/self.size.height);
        [self.stream2Filter setMiscMapFramebuffer:self.miscPP.getOldFbo.outputFramebuffer dist2MapFramebuffer:self.dist2PP.getOldFbo.outputFramebuffer];
        [self.stream2Filter newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        [self.dist2PP swap];
        
        self.getVelDenFilter.renderFramebuffer=[self.velDenPP getNewFbo].outputFramebuffer;
        [self.getVelDenFilter setWf_MUl:uniforms.wf_mul evapor:uniforms.evapor];
        [self.getVelDenFilter setMiscMapFramebuffer:self.miscPP.getOldFbo.outputFramebuffer dist1MapFramebuffer:self.dist1PP.getOldFbo.outputFramebuffer dist2MapFramebuffer:self.dist2PP.getOldFbo.outputFramebuffer velDenMapFramebuffer:self.velDenPP.getOldFbo.outputFramebuffer];
        [self.getVelDenFilter newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        [self.velDenPP swap];
        
        self.inkSupplyFilter.renderFramebuffer=[self.surfInkPP getNewFbo].outputFramebuffer;
        [self.inkSupplyFilter setVelDenMap:self.velDenPP.getOldFbo.outputFramebuffer surfInkMap:self.surfInkPP.getOldFbo.outputFramebuffer miscMap:self.miscPP.getOldFbo.outputFramebuffer];
        [self.inkSupplyFilter newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        [self.surfInkPP swap];
        
        self.inkXAmtFilter.renderFramebuffer=[self.sinkInkPP getNewFbo].outputFramebuffer;
        [self.inkXAmtFilter setFixRateComp0:uniforms.f1 comp1:uniforms.f2 comp2:uniforms.f3];
        [self.inkXAmtFilter setVelDenMapFramebuffer:self.velDenPP.getOldFbo.outputFramebuffer miscMapFramebuffer:self.miscPP.getOldFbo.outputFramebuffer flowInkMapFramebuffer:self.flowInkPP.getOldFbo.outputFramebuffer fixInkMapFramebuffer:self.fixInkPP.getOldFbo.outputFramebuffer];
        [self.inkXAmtFilter newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        [self.sinkInkPP swap];
        
        self.inkXToFilter.renderFramebuffer=[self.fixInkPP getNewFbo].outputFramebuffer;
        [self.inkXToFilter setFixInkMapFramebuffer:self.fixInkPP.getOldFbo.outputFramebuffer sinkInkMapFramebuffer:self.sinkInkPP.getOldFbo.outputFramebuffer velDenFramebuffer:self.velDenPP.getOldFbo.outputFramebuffer];
        [self.inkXToFilter newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        [self.fixInkPP swap];
        
        self.inkXFrFilter.renderFramebuffer=[self.flowInkPP getNewFbo].outputFramebuffer;
        [self.inkXFrFilter setFlowInkMapFramebuffer:self.flowInkPP.getOldFbo.outputFramebuffer sinkInkMapFramebuffer:self.sinkInkPP.getOldFbo.outputFramebuffer];
        [self.inkXFrFilter newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        [self.flowInkPP swap];
        
        self.inkFlowFilter.renderFramebuffer=[self.flowInkPP getNewFbo].outputFramebuffer;
        [self.inkFlowFilter setBlk_aComp0:uniforms.ba1 comp1:uniforms.ba2];
        self.inkFlowFilter.offset=CGSizeMake(1/self.size.width, 1/self.size.height);
        [self.inkFlowFilter setVelDenMap:self.velDenPP.getOldFbo.outputFramebuffer miscMap:self.miscPP.getOldFbo.outputFramebuffer dist1Map:self.dist1PP.getOldFbo.outputFramebuffer dist2Map:self.dist2PP.getOldFbo.outputFramebuffer flowInkMap:self.flowInkPP.getOldFbo.outputFramebuffer surfInkMap:self.surfInkPP.getOldFbo.outputFramebuffer];
        [self.inkFlowFilter newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
        [self.flowInkPP swap];
    });    
}

- (void)draw
{
    runAsynchronouslyOnVideoProcessingQueue(^{
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        FZFramebuffer *inkFixFbo=self.fixInkPP.getOldFbo;
        [self.getXYZFilter addTarget:self.renderView];
        [inkFixFbo feedFramebufferToFilter:self.getXYZFilter];
    });
}

- (void)drawBlock:(void (^)(FZFramebuffer *))drawBlock
{
    if (drawBlock) {
        runAsynchronouslyOnVideoProcessingQueue(^{
            drawBlock(self.fboDepositionBuffer);
        });
    }
}

@end

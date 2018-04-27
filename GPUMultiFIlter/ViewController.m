//
//  ViewController.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2017/12/28.
//  Copyright © 2017年 周维鸥. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>
#import "FilterCircle.h"
#import "FilterLine.h"
#import "FZTexture.h"
#import "FZFramebuffer.h"
#import "TestDraw.h"
#import "FZFramebufferPingPong.h"
#import "FZInkSim.h"
#import "FZPassthroughFilter.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) FZTexture *brushTexture;
@property (strong, nonatomic) FZFramebufferPingPong *fboPingPong;
@property (strong, nonatomic) FZInkSim *inkSim;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _brushTexture=[[FZTexture alloc] initWithImage:[UIImage imageNamed:@"test2"]];
    self.imageView.fillMode=kGPUImageFillModeStretch;
}

- (void)startDraw
{
    // 一定要放主线程否则运行一次后就停止了
    runOnMainQueueWithoutDeadlocking(^{
        if (self.displayLink == nil) {
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
            self.displayLink.frameInterval=10;
            [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
    });
}

- (void)stopDraw
{
    [self.displayLink invalidate];
    self.displayLink = nil;
    _fboPingPong=nil;
}

- (IBAction)onButtonProcess:(id)sender {
    [self test];
}

- (void)test
{
    CGSize size=_imageView.frame.size;
    CGFloat contentScale = [[UIScreen mainScreen] scale];
    size=CGSizeMake(size.width*contentScale, size.height*contentScale);
    [self.inkSim drawBlock:^(FZFramebuffer *fboDepositionBuffer) {
        [fboDepositionBuffer beginDrawingWithRenderbufferSize:size];
        [TestDraw drawRandomRect];
//        [fboDepositionBuffer endDrawing];
        [self.inkSim beginDebug];
//        [self.inkSim draw];
    }];
}

- (void)drawFrame
{
    [self.inkSim update];
    [self.inkSim draw];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGSize size=_imageView.frame.size;
    CGFloat contentScale = [[UIScreen mainScreen] scale];
    size=CGSizeMake(size.width*contentScale, size.height*contentScale);
    glViewport(0, 0, size.width,size.height);
    self.inkSim=[[FZInkSim alloc] initWithRenderView:self.imageView];
    [self.inkSim setupWithSize:size];
//    [self.inkSim drawBlock:^(FZFramebuffer *fboDepositionBuffer) {
//        [fboDepositionBuffer beginDrawingWithRenderbufferSize:size];
//        [TestDraw drawRandomRect];
//        [fboDepositionBuffer endDrawing];
//    }];
    [self startDraw];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.inkSim drawBlock:^(FZFramebuffer *fboDepositionBuffer) {
//            [fboDepositionBuffer beginDrawingWithRenderbufferSize:size];
//            [TestDraw drawRandomRect];
//            [fboDepositionBuffer endDrawing];
//        }];
//    });
    
//    runAsynchronouslyOnVideoProcessingQueue(^{
//        FZFramebuffer *fbo=[[FZFramebuffer alloc] initWithSize:size];
//        [fbo beginDrawingWithRenderbufferSize:size];
//        [TestDraw drawRandomRect];
//        [fbo endDrawing];
//        [fbo feedFramebufferToFilter:self.imageView];
//    });
}

@end

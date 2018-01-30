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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) FZTexture *grainTexture;
@property (strong, nonatomic) FZTexture *alumTexture;
@property (strong, nonatomic) FZTexture *pinningTexture;
@property (strong, nonatomic) FZTexture *brushTexture;
@property (strong, nonatomic) FZFramebufferPingPong *fboPingPong;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    int num_texture_units;
    glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &num_texture_units);
    NSLog(@"max texture %zd",num_texture_units);
}

- (void)setup
{
    _grainTexture=[[FZTexture alloc] initWithImage:[UIImage imageNamed:@"grain.jpg"]];
    _alumTexture=[[FZTexture alloc] initWithImage:[UIImage imageNamed:@"alum3"]];
    _pinningTexture=[[FZTexture alloc] initWithImage:[UIImage imageNamed:@"pinning"]];
    _brushTexture=[[FZTexture alloc] initWithImage:[UIImage imageNamed:@"test2"]];
}

- (void)startDraw
{
    // 一定要放主线程否则运行一次后就停止了
    runOnMainQueueWithoutDeadlocking(^{
        if (self.displayLink == nil) {
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
            self.displayLink.frameInterval=3;
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
    glViewport(0, 0, size.width,size.height);
	runAsynchronouslyOnVideoProcessingQueue(^{        
        self.fboPingPong=[[FZFramebufferPingPong alloc] initWithSize:size];
        FZFramebuffer *fbo=[self.fboPingPong getNewFbo];
        GPUImagePicture *picture=[[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"3.jpg"]];
        [picture addTarget:fbo];
        [fbo addTarget:self.imageView];
        [picture processImage];
        [self.fboPingPong swap];
        [self startDraw];
    });
}

- (void)drawFrame
{
    runAsynchronouslyOnVideoProcessingQueue(^{
        FZFramebuffer *fboRead=[self.fboPingPong getOldFbo];
        FZFramebuffer *fboWrite=[self.fboPingPong getNewFbo];
        FilterLine *filter=[FilterLine new];
        [filter addTarget:fboWrite];
        [fboWrite addTarget:self.imageView];
        [fboRead feedFramebufferToFilter:filter];
        [self.fboPingPong swap];
    });
}

@end

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
@property (strong, nonatomic) FZTexture *imageTexture;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) CGFloat currentLos;
@property (strong, nonatomic) FZFramebufferPingPong *fboPingPong;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // _imageTexture=[[FZTexture alloc] initWithImage:[UIImage imageNamed:@"3.jpg"]];
    self.currentLos=-1.0;
    int num_texture_units;
    glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &num_texture_units);
    NSLog(@"max texture %zd",num_texture_units);
}

- (void)startDraw
{
    // 一定要放主线程否则运行一次后就停止了
    runOnMainQueueWithoutDeadlocking(^{
        _timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(drawFrame) userInfo:nil repeats:YES];
        [_timer fire];
    });
}

- (void)stopDraw
{
    [_timer invalidate];
    _timer=nil;
    _fboPingPong=nil;
    _currentLos=0.0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (self.currentLos>1.0) {
        [self stopDraw];
        return;
    }
    runAsynchronouslyOnVideoProcessingQueue(^{
        NSLog(@"%f",self.currentLos);
        FZFramebuffer *fboRead=[self.fboPingPong getOldFbo];
        FZFramebuffer *fboWrite=[self.fboPingPong getNewFbo];
        FilterLine *filter=[FilterLine new];
        filter.pos=self.currentLos;
        self.currentLos += 0.1;
        [filter addTarget:fboWrite];
        [fboWrite addTarget:self.imageView];
        [fboRead feedFramebufferToFilter:filter];
        [self.fboPingPong swap];
    });
}

@end

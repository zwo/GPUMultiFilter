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
@interface ViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) FZTexture *imageTexture;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // _imageTexture=[[FZTexture alloc] initWithImage:[UIImage imageNamed:@"3.jpg"]];
}

- (void)startDraw
{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopDraw
{
    [_displayLink invalidate];
    _displayLink=nil;
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
        FZFramebuffer *fbo=[[FZFramebuffer alloc] initWithSize:size];
        [fbo beginDrawingWithRenderbufferSize:size];
        [TestDraw drawRect];
        [fbo endDrawing];
        [fbo feedFramebufferToFilter:self.imageView];
    });
}

- (void)drawFrame
{
    
}

@end

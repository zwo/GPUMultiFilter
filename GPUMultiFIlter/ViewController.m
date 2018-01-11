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

@property (strong, nonatomic) FZTexture *imageTexture;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // _imageTexture=[[FZTexture alloc] initWithImage:[UIImage imageNamed:@"3.jpg"]];
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
	runAsynchronouslyOnVideoProcessingQueue(^{        
        FZFramebuffer *fbo=[[FZFramebuffer alloc] initWithSize:CGSizeMake(261,172)];
        [fbo beginDrawingWithRenderbufferSize:CGSizeMake(261, 172)];
        [TestDraw drawRect];
        [fbo endDrawing];
        [fbo feedFramebufferToFilter:self.imageView];        
    });
	

}

@end

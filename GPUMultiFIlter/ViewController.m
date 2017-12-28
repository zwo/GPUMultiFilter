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
@interface ViewController ()
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"3.jpg"]];
    [picture addTarget:_imageView];
    [picture processImage];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButtonProcess:(id)sender {
    FilterCircle *filter=[FilterCircle new];
    FilterLine *filter2=[FilterLine new];
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"3.jpg"]];
    [picture addTarget:filter];
    [filter addTarget:filter2];
    [filter2 addTarget:_imageView];
    [picture processImage];
}

@end

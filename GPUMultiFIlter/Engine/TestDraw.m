//
//  TestDraw.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/5.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "TestDraw.h"
#import "FZInkSim.h"

static NSString *const kRectVertShader = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 SourceColor;
 
 varying vec4 DestinationColor;
 
 void main(void) {
     DestinationColor = SourceColor;
     gl_Position = position;
 }
);

static NSString *const kRectFragShader = SHADER_STRING
(
 varying lowp vec4 DestinationColor;
 
 void main(void) {
     gl_FragColor = DestinationColor;
 }
);

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};


@implementation TestDraw

+ (void)drawRect
{
    [GPUImageContext useImageProcessingContext];
    GLProgram *program=[[GLProgram alloc] initWithVertexShaderString:kRectVertShader fragmentShaderString:kRectFragShader];
    [program addAttribute:@"position"];
    [program addAttribute:@"SourceColor"];
    [self linkProgram:program];
    GLint positionAttrib=[program attributeIndex:@"position"];
    GLint sourceColorAttrib=[program attributeIndex:@"SourceColor"];
    [GPUImageContext setActiveShaderProgram:program];
    glEnableVertexAttribArray(positionAttrib);
    glEnableVertexAttribArray(sourceColorAttrib);
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);

//    glViewport(0, 0, 128, 128);
    glVertexAttribPointer(positionAttrib, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(sourceColorAttrib, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);    
}

static int randomNumberRange(int from, int to)
{
    return (int)(from + (arc4random() % (to - from + 1))); //+1,result is [from to]; else is [from, to)!!!!!!!
}

+ (void)drawRandomRect
{
    CGFloat width=randomNumberRange(20, 30)*0.01; // 0.2 ~ 0.3
    CGFloat posX=randomNumberRange(-10, 10)*0.1; // -1 ~ 1
    CGFloat posY=randomNumberRange(-10, 10)*0.1; // -1 ~ 1
    CGFloat hueAngle=(CGFloat)randomNumberRange(0, 360);
    UIColor *ramdomColor=[FZInkSim getInkColorHueAngle:hueAngle];
    CGFloat r,g,b;
    [ramdomColor getRed:&r green:&g blue:&b alpha:nil];
    
    Vertex lr={{posX+width,posY-width,0},{r,g,b,1}};
    Vertex ur={{posX+width,posY,0},{r,g,b,1}};
    Vertex ul={{posX,posY,0},{r,g,b,1}};
    Vertex ll={{posX,posY-width,0},{r,g,b,1}};
    Vertex rectVertex[]={lr,ur,ul,ll};
    [GPUImageContext useImageProcessingContext];
    GLProgram *program=[[GLProgram alloc] initWithVertexShaderString:kRectVertShader fragmentShaderString:kRectFragShader];
    [program addAttribute:@"position"];
    [program addAttribute:@"SourceColor"];
    [self linkProgram:program];
    GLint positionAttrib=[program attributeIndex:@"position"];
    GLint sourceColorAttrib=[program attributeIndex:@"SourceColor"];
    [GPUImageContext setActiveShaderProgram:program];
    glEnableVertexAttribArray(positionAttrib);
    glEnableVertexAttribArray(sourceColorAttrib);
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(rectVertex), rectVertex, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //    glViewport(0, 0, 128, 128);
    glVertexAttribPointer(positionAttrib, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(sourceColorAttrib, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

+ (BOOL)linkProgram:(GLProgram *)program
{
    if (![program link])
    {
        NSString *progLog = [program programLog];
        NSLog(@"Program link log: %@", progLog);
        NSString *fragLog = [program fragmentShaderLog];
        NSLog(@"Fragment shader compile log: %@", fragLog);
        NSString *vertLog = [program vertexShaderLog];
        NSLog(@"Vertex shader compile log: %@", vertLog);
        program = nil;
        NSAssert(NO, @"Filter shader link failed");
    }
    return YES;
}

+ (UIImage *)imageWithBuffer:(GLubyte *)buffer ofSize:(CGSize)size
{
    GLint width = size.width;
    GLint height = size.height;
    
    NSInteger myDataLength = width * height * 4;
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, myDataLength, NOCReleaseDataBuffer);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    UIImage *myImage = [[UIImage alloc] initWithCGImage:imageRef
                                                  scale:1
                                            orientation:UIImageOrientationUp];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpaceRef);
    
    return myImage;
}

static void NOCReleaseDataBuffer( void *p , const void *cp , size_t l ) {
    free((void *)cp);
}

@end

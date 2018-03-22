//
//  TestDraw.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/5.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "TestDraw.h"

static NSString *const kRectVertShader = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 SourceColor;
 attribute vec2 TexCoordIn;
 varying vec4 DestinationColor;
 varying vec2 TexCoordOut;
 
 void main(void) {
     DestinationColor = SourceColor;
     gl_Position = position;
     TexCoordOut = TexCoordIn;
 }
);

static NSString *const kRectFragShader = SHADER_STRING
(
 varying lowp vec4 DestinationColor;
 
 varying lowp vec2 TexCoordOut;
 uniform sampler2D Texture;
 void main(void) {
     gl_FragColor = mix(DestinationColor,texture2D(Texture, TexCoordOut),0.9);
 }
);

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}, {1,0}},
    {{1, 1, 0}, {0, 1, 0, 1}, {1,1}},
    {{-1, 1, 0}, {0, 0, 1, 1}, {0,1}},
    {{-1, -1, 0}, {0, 0, 0, 1}, {0,0}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};


@implementation TestDraw

+ (void)drawRect
{
//    [GPUImageContext useImageProcessingContext];
    GLProgram *program=[[GLProgram alloc] initWithVertexShaderString:kRectVertShader fragmentShaderString:kRectFragShader];
    [program addAttribute:@"position"];
    [program addAttribute:@"SourceColor"];
    [program addAttribute:@"TexCoordIn"];
    [self linkProgram:program];
    GLenum errCode = glGetError();
    if (errCode!=GL_NO_ERROR) {
        NSLog(@"%s:%d error code %zd",__PRETTY_FUNCTION__,__LINE__, errCode);
    }
    GLint positionAttrib=[program attributeIndex:@"position"];
    GLint sourceColorAttrib=[program attributeIndex:@"SourceColor"];
    GLint texCoordSlot = [program attributeIndex:@"TexCoordIn"];
    GLint textureUniform = [program uniformIndex:@"Texture"];
    
    errCode = glGetError();
    if (errCode!=GL_NO_ERROR) {
        NSLog(@"%s:%d error code %zd",__PRETTY_FUNCTION__,__LINE__, errCode);
    }
    
//    [GPUImageContext setActiveShaderProgram:program];
    [program use];
    glEnableVertexAttribArray(positionAttrib);
    glEnableVertexAttribArray(sourceColorAttrib);
    glEnableVertexAttribArray(texCoordSlot);
    
    
    
    errCode = glGetError();
    if (errCode!=GL_NO_ERROR) {
        NSLog(@"%s:%d error code %zd",__PRETTY_FUNCTION__,__LINE__, errCode);
    }
    
    GLint picTexture=[self setupTexture:@"3.jpg"];
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, 261, 172);
    glVertexAttribPointer(positionAttrib, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(sourceColorAttrib, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    
    glVertexAttribPointer(texCoordSlot, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, picTexture);
    glUniform1i(textureUniform, 0);
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
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

/**
 *  加载image, 使用CoreGraphics将位图以RGBA格式存放. 将UIImage图像数据转化成OpenGL ES接受的数据.
 *  然后在GPU中将图像纹理传递给GL_TEXTURE_2D。
 *  @return 返回的是纹理对象，该纹理对象暂时未跟GL_TEXTURE_2D绑定（要调用bind）。
 *  即GL_TEXTURE_2D中的图像数据都可从纹理对象中取出。
 */
+ (GLuint)setupTexture:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    CGImageRef cgImageRef = [image CGImage];
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    
//    glEnable(GL_TEXTURE_2D);
    /**
     *  GL_TEXTURE_2D表示操作2D纹理
     *  创建纹理对象，
     *  绑定纹理对象，
     */
    GLuint textureID;
    glGenTextures(1, &textureID);
    
    glBindTexture(GL_TEXTURE_2D, textureID);
    /**
     *  纹理过滤函数
     *  图象从纹理图象空间映射到帧缓冲图象空间(映射需要重新构造纹理图像,这样就会造成应用到多边形上的图像失真),
     *  这时就可用glTexParmeteri()函数来确定如何把纹理象素映射成像素.
     *  如何把图像从纹理图像空间映射到帧缓冲图像空间（即如何把纹理像素映射成像素）
     */
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // S方向上的贴图模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); // T方向上的贴图模式
    // 线性过滤：使用距离当前渲染像素中心最近的4个纹理像素加权平均值
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    /**
     *  将图像数据传递给到GL_TEXTURE_2D中, 因其于textureID纹理对象已经绑定，所以即传递给了textureID纹理对象中。
     *  glTexImage2d会将图像数据从CPU内存通过PCIE上传到GPU内存。
     *  不使用PBO时它是一个阻塞CPU的函数，数据量大会卡。
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    // 结束后要做清理
    glBindTexture(GL_TEXTURE_2D, 0); //解绑
    CGContextRelease(context);
    free(imageData);
    return textureID;
}

@end

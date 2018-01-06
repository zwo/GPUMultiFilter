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
    
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, 128, 128);
    glVertexAttribPointer(positionAttrib, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(sourceColorAttrib, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    
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

@end

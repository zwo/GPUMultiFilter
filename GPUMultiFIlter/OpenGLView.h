//
//  OpenGLView.h
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/9.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
@interface OpenGLView : UIView{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
}

@end

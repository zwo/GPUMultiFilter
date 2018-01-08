//
//  FZTexture.m
//  GPUMultiFIlter
//
//  Created by 周维鸥 on 2018/1/3.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "FZTexture.h"

@interface FZTexture ()
@property (strong, nonatomic) dispatch_semaphore_t imageUpdateSemaphore;
@property (strong, nonatomic) GPUImageFramebuffer *outputFramebuffer;
@end

@implementation FZTexture

- (instancetype)initWithImage:(UIImage *)image
{
    if (!(self = [super init]))
    {
        return nil;
    }
    _imageUpdateSemaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_signal(_imageUpdateSemaphore);
    CGImageRef newImageSource=[image CGImage];
    CGFloat widthOfImage = CGImageGetWidth(newImageSource);
    CGFloat heightOfImage = CGImageGetHeight(newImageSource);
    // If passed an empty image reference, CGContextDrawImage will fail in future versions of the SDK.
    NSAssert( widthOfImage > 0 && heightOfImage > 0, @"Passed image must not be empty - it should be at least 1px tall and wide");
    CGSize pixelSizeToUseForTexture = CGSizeMake(widthOfImage, heightOfImage);
    BOOL shouldRedrawUsingCoreGraphics = NO;
    // For now, deal with images larger than the maximum texture size by resizing to be within that limit
    CGSize scaledImageSizeToFitOnGPU = [GPUImageContext sizeThatFitsWithinATextureForSize:pixelSizeToUseForTexture];
    if (!CGSizeEqualToSize(scaledImageSizeToFitOnGPU, pixelSizeToUseForTexture))
    {
        pixelSizeToUseForTexture = scaledImageSizeToFitOnGPU;
        shouldRedrawUsingCoreGraphics = YES;
    }
    GLubyte *imageData = NULL;
    CFDataRef dataFromImageDataProvider = NULL;
    GLenum format = GL_BGRA;
    BOOL isLitteEndian = YES;
    BOOL alphaFirst = NO;
    
    if (!shouldRedrawUsingCoreGraphics) {
        /* Check that the memory layout is compatible with GL, as we cannot use glPixelStore to
         * tell GL about the memory layout with GLES.
         */
        if (CGImageGetBytesPerRow(newImageSource) != CGImageGetWidth(newImageSource) * 4 ||
            CGImageGetBitsPerPixel(newImageSource) != 32 ||
            CGImageGetBitsPerComponent(newImageSource) != 8)
        {
            shouldRedrawUsingCoreGraphics = YES;
        } else {
            /* Check that the bitmap pixel format is compatible with GL */
            CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(newImageSource);
            if ((bitmapInfo & kCGBitmapFloatComponents) != 0) {
                /* We don't support float components for use directly in GL */
                shouldRedrawUsingCoreGraphics = YES;
            } else {
                CGBitmapInfo byteOrderInfo = bitmapInfo & kCGBitmapByteOrderMask;
                if (byteOrderInfo == kCGBitmapByteOrder32Little) {
                    /* Little endian, for alpha-first we can use this bitmap directly in GL */
                    CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
                    if (alphaInfo != kCGImageAlphaPremultipliedFirst && alphaInfo != kCGImageAlphaFirst &&
                        alphaInfo != kCGImageAlphaNoneSkipFirst) {
                        shouldRedrawUsingCoreGraphics = YES;
                    }
                } else if (byteOrderInfo == kCGBitmapByteOrderDefault || byteOrderInfo == kCGBitmapByteOrder32Big) {
                    isLitteEndian = NO;
                    /* Big endian, for alpha-last we can use this bitmap directly in GL */
                    CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
                    if (alphaInfo != kCGImageAlphaPremultipliedLast && alphaInfo != kCGImageAlphaLast &&
                        alphaInfo != kCGImageAlphaNoneSkipLast) {
                        shouldRedrawUsingCoreGraphics = YES;
                    } else {
                        /* Can access directly using GL_RGBA pixel format */
                        alphaFirst = alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaPremultipliedFirst;
                        format = GL_RGBA;
                    }
                }
            }
        }
    }
    
    //    CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
    
    if (shouldRedrawUsingCoreGraphics)
    {
        // For resized or incompatible image: redraw
        imageData = (GLubyte *) calloc(1, (int)pixelSizeToUseForTexture.width * (int)pixelSizeToUseForTexture.height * 4);
        
        CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)pixelSizeToUseForTexture.width, (size_t)pixelSizeToUseForTexture.height, 8, (size_t)pixelSizeToUseForTexture.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        //        CGContextSetBlendMode(imageContext, kCGBlendModeCopy); // From Technical Q&A QA1708: http://developer.apple.com/library/ios/#qa/qa1708/_index.html
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, pixelSizeToUseForTexture.width, pixelSizeToUseForTexture.height), newImageSource);
        CGContextRelease(imageContext);
        CGColorSpaceRelease(genericRGBColorspace);
        isLitteEndian = YES;
        alphaFirst = YES;        
    }
    else
    {
        // Access the raw image bytes directly
        dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(newImageSource));
        imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        GPUTextureOptions defaultTextureOptions;
        defaultTextureOptions.minFilter = GL_LINEAR;
        defaultTextureOptions.magFilter = GL_LINEAR;
        defaultTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
        defaultTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
        defaultTextureOptions.internalFormat = GL_RGBA;
        defaultTextureOptions.format = GL_BGRA;
        defaultTextureOptions.type = GL_UNSIGNED_BYTE;
        
        _outputFramebuffer = [[GPUImageFramebuffer alloc] initWithSize:pixelSizeToUseForTexture textureOptions:defaultTextureOptions onlyTexture:YES];
        [_outputFramebuffer disableReferenceCounting];
        
        glBindTexture(GL_TEXTURE_2D, [_outputFramebuffer texture]);
        
        // no need to use self.outputTextureOptions here since pictures need this texture formats and type
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)pixelSizeToUseForTexture.width, (int)pixelSizeToUseForTexture.height, 0, format, GL_UNSIGNED_BYTE, imageData);        
        
        glBindTexture(GL_TEXTURE_2D, 0);
    });
    
    if (shouldRedrawUsingCoreGraphics)
    {
        free(imageData);
    }
    else
    {
        if (dataFromImageDataProvider)
        {
            CFRelease(dataFromImageDataProvider);
        }
    }
    _texturePixelSize=pixelSizeToUseForTexture;
    return self;
}

- (void)dealloc;
{    
#if !OS_OBJECT_USE_OBJC
    if (_imageUpdateSemaphore != NULL)
    {
        dispatch_release(_imageUpdateSemaphore);
    }
#endif
}

- (void)processTextureToFilter:(id<GPUImageInput>)filter
{
    NSInteger nextAvailableTextureIndex = [filter nextAvailableTextureIndex];
//    if (dispatch_semaphore_wait(_imageUpdateSemaphore, DISPATCH_TIME_NOW) != 0)
//    {
//        return;
//    }
    runAsynchronouslyOnVideoProcessingQueue(^{
        [filter setCurrentlyReceivingMonochromeInput:NO];
        [filter setInputSize:self.texturePixelSize atIndex:nextAvailableTextureIndex];
        [filter setInputFramebuffer:self.outputFramebuffer atIndex:nextAvailableTextureIndex];
        [filter newFrameReadyAtTime:kCMTimeIndefinite atIndex:nextAvailableTextureIndex];
    });
}


@end

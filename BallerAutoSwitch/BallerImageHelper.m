//
//  BallerImageHelper.m
//  Baller
//
//  Created by Ping Chen on 12/13/17.
//

#import "BallerImageHelper.h"


@implementation BallerImageHelper


+ (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    @autoreleasepool {
        CGSize frameSize = CGSizeMake(CGImageGetWidth(image),
                                      CGImageGetHeight(image));
        NSDictionary *options =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES],
         kCVPixelBufferCGImageCompatibilityKey,
         [NSNumber numberWithBool:YES],
         kCVPixelBufferCGBitmapContextCompatibilityKey,
         nil];
        CVPixelBufferRef pxbuffer = NULL;
        
        CVReturn status =
        CVPixelBufferCreate(
                            kCFAllocatorDefault, frameSize.width, frameSize.height,
                            kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options,
                            &pxbuffer);
        NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
        
        CVPixelBufferLockBaseAddress(pxbuffer, 0);
        void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
        
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(
                                                     pxdata, frameSize.width, frameSize.height,
                                                     8, CVPixelBufferGetBytesPerRow(pxbuffer),
                                                     rgbColorSpace,
                                                     (CGBitmapInfo)kCGBitmapByteOrder32Little |
                                                     kCGImageAlphaPremultipliedFirst);
        
        CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                               CGImageGetHeight(image)), image);
        CGColorSpaceRelease(rgbColorSpace);
        CGContextRelease(context);
        
        CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
        
        return pxbuffer;
    }
}

@end

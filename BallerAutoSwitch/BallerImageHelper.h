//
//  BallerImageHelper.h
//  Baller
//
//  Created by Ping Chen on 12/13/17.
//

#import <Foundation/Foundation.h>



@interface BallerImageHelper : NSObject

+ (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image;

@end

//
//  BallerImageProcessController.h
//  Baller
//
//  Created by Ping Chen on 12/13/17.
//

#import <Foundation/Foundation.h>

@interface BallerImageProcessController : NSObject

- (instancetype)init;


- (UIImage *)backgroundFuckery:(UIImage *)img;

- (UIImage *)thresholdedImage:(UIImage *)img;

- (float)computeMotionIntensity:(UIImage *)image;


@end

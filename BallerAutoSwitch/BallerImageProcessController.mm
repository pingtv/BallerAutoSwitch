//
//  BallerSwitchingController.m
//  Baller
//
//  Created by Ping Chen on 12/13/17.
//

#import "BallerImageProcessController.h"
#import "BallerImageHelper.h"
#import <CoreImage/CoreImage.h>

#ifdef __cplusplus
#include <stdlib.h>
#import <opencv2/videoio/cap_ios.h>
#endif

using namespace cv;
using namespace std;


@interface BallerImageProcessController ()

#ifdef __cplusplus
@property std::deque<cv::Mat> ring;

@property Ptr<BackgroundSubtractorMOG2> bgMOG2;
#endif

@end

int gaussianBlurDimension; // must be odd
int binaryThreshold;
double accumulationAlpha;


@implementation BallerImageProcessController

- (instancetype)init {
    
    self = [super init];
    
    gaussianBlurDimension = 3;
    binaryThreshold = 25;
    accumulationAlpha = 0.03;
    
    _bgMOG2 = cv::createBackgroundSubtractorMOG2(5);
    
    return self;
}


#ifdef __cplusplus
- (UIImage *)backgroundFuckery:(UIImage *)img {
    
    cv::Mat image = [[self class] cvMatFromUIImage:img];
    int rows = image.rows;
    int cols = image.cols;
    
    cv::Mat fgMask;
    _bgMOG2->apply(image, fgMask);
    
//    cv::Mat bground(rows, cols, CV_8UC1);
//    _bgMOG2->getBackgroundImage(bground);
    
    UIImage *answer = [[self class] UIImageFromCVMat:fgMask];
    
    fgMask.release();
    image.release();
    
    return answer;
    
}


- (UIImage *)thresholdedImage:(UIImage *)img {
    UIImage *thresholdedImage = img;
    
    cv::Mat image = [[self class] cvMatFromUIImage:img];
    CGFloat ogCols = image.cols;
    CGFloat ogRows = image.rows;
    CGFloat ratio = ogCols/ogRows;
    
    cv::resize(image, image, cv::Size(ratio * 360, 360));
    
    
    CGFloat cols = image.cols;
    CGFloat rows = image.rows;
    
    // convert to grayscale and blur
    cv::Mat gray(rows, cols, CV_32FC1);
    cv::cvtColor(image, gray, CV_BGRA2GRAY);
//    cv::GaussianBlur(gray, gray, cv::Size(gaussianBlurDimension, gaussianBlurDimension), 0);

    
    if (_ring.size() >= 2) {
        
        // compute the absolute difference between the current frame and past
        cv::Mat frameDelta1(rows, cols, 0);
        cv::Mat frameDelta2(rows, cols, 0);
        cv::Mat frameDelta(rows, cols, 0);
        cv::absdiff(_ring[0], _ring[1],frameDelta1);
        cv::absdiff(_ring[1], gray, frameDelta2);
        cv::bitwise_or(frameDelta1, frameDelta2, frameDelta);
        
        
        // Apply threshold
        cv::Mat thresh;
        cv::threshold(frameDelta, thresh, binaryThreshold, 255, THRESH_BINARY);
        thresh.convertTo(thresh, CV_8UC(thresh.channels()));
        
        
        thresholdedImage = [[self class] UIImageFromCVMat:frameDelta];
        
        
//        avgImg.release();
        frameDelta1.release();
        frameDelta2.release();
        frameDelta.release();
        thresh.release();

        
    }
    
    // add grayscale version to ringbuffer
    _ring.push_back(gray);

    if (_ring.size() > 2) {
        Mat temp = _ring.front();
        _ring.pop_front();
        temp.release();
    }
    
    return thresholdedImage;
    
}


- (float)computeMotionIntensity:(UIImage *)img {

    double motionValue = 0;
    
    cv::Mat image = [[self class] cvMatFromUIImage:img];
    CGFloat ogCols = image.cols;
    CGFloat ogRows = image.rows;
    CGFloat ratio = ogCols/ogRows;
    
    cv::resize(image, image, cv::Size(ratio * 360, 360));
    
    
    CGFloat cols = image.cols;
    CGFloat rows = image.rows;
    
    // convert to grayscale and blur
    cv::Mat gray(rows, cols, CV_32FC1);
    cv::cvtColor(image, gray, CV_BGRA2GRAY);
    //    cv::GaussianBlur(gray, gray, cv::Size(gaussianBlurDimension, gaussianBlurDimension), 0);
    
    if (_ring.size() >= 2) {
        
        // compute the absolute difference between the current frame and past
        cv::Mat frameDelta1(rows, cols, 0);
        cv::Mat frameDelta2(rows, cols, 0);
        cv::Mat frameDelta(rows, cols, 0);
        cv::absdiff(_ring[0], _ring[1],frameDelta1);
        cv::absdiff(_ring[1], gray, frameDelta2);
        cv::bitwise_or(frameDelta1, frameDelta2, frameDelta);
        
        
        // Apply threshold
        cv::Mat thresh;
        cv::threshold(frameDelta, thresh, binaryThreshold, 255, THRESH_BINARY);
        thresh.convertTo(thresh, CV_8UC(thresh.channels()));


        // Find all contours
        std::vector<std::vector<cv::Point> > contours;
        cv::findContours(thresh, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);


        // Count all motion areas
        
        double maxArea = 1.0/10 * rows * cols;
        double minArea = 1.0/2000 * rows * cols;
//        std::vector<std::vector<cv::Point> > motionAreas;
        for (int i = 0; i < contours.size(); i++) {
            double area = cv::contourArea(contours[i]);
            //only count motion above a certain size (filter some artifacts)
            if (area < maxArea && area > minArea){
//                motionAreas.push_back(contours[i]);
//                motionValue += area;
                motionValue += 1;
            }

        }


        frameDelta.release();
        thresh.release();

    }

    // add grayscale version to ringbuffer
    _ring.push_back(gray);

    if (_ring.size() > 2) {
        Mat temp = _ring.front();
        _ring.pop_front();
        temp.release();
    }

    image.release();
    
    return motionValue;

}


+ (cv::Mat)cvMatFromUIImage:(UIImage *)image {

    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;

}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;

    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );


    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return finalImage;
}
#endif


@end

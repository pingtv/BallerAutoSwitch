#import "NSXCustomCaptureSession.h"
#import "NSXTimer.h"

@interface NSXCustomCaptureSession ()

@property (nonatomic, strong) NSXTimer* timer;
@property (nonatomic, assign) CMTime firstPts;
@property (nonatomic, assign) CMTime firstDts;

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation NSXCustomCaptureSession

-(id) init
{
    self = [super init];
    
    if(self)
    {
        _timer = [[NSXTimer alloc] init];
        _serialQueue = dispatch_queue_create("serial_queue", DISPATCH_QUEUE_SERIAL);
        [self reset];
    }
    
    return self;
}

-(void) reset
{
    dispatch_sync(_serialQueue, ^{
        _firstPts = kCMTimeInvalid;
        _firstDts = kCMTimeInvalid;
    });
}

-(void) addInput:(AVCaptureInput *)input
{
    [super addInput:input];
}

-(void) addOutput:(AVCaptureOutput *)output
{
    if ([output isKindOfClass:[AVCaptureVideoDataOutput class]]) {
        self.myVideoOutput = (AVCaptureVideoDataOutput*)output;
    }else if([output isKindOfClass:[AVCaptureAudioDataOutput class]])
    {
        //self.myAudioOutput = (AVCaptureAudioDataOutput*)output; // if you want to use a custom audio capture device
        [super addOutput: output]; // uses the standard microphone of the iOS device
    }
}

-(void) startRunning
{
    [super startRunning];
}

-(void) stopRunning
{
    [super stopRunning];
}

// this method has to be called periodically - e.g. with CADisplayLink
-(void) supplyVideoBuffer:(CVImageBufferRef)buffer
{
    if(buffer == NULL) {
        return;
    }
    
    CMTime pts = CMTimeMake([self.timer getTime], 1000);    // timestamp information required
    CMTime dts = pts;
    CMTime dur = CMTimeMake(33, 1000);    // assuming 30fps, change if otherwise
    
    [self supplyVideoBuffer:buffer withPts:pts withDts:dts andDuration:dur];
    
}

// this method has to be called periodically - e.g. with CADisplayLink
-(void) supplyVideoBuffer:(CVImageBufferRef)buffer withPts:(CMTime)pts withDts:(CMTime)dts andDuration:(CMTime)dur {
    dispatch_sync(_serialQueue, ^{
        CMSampleBufferRef newSampleBuffer = NULL;
        
        if(CMTIME_IS_INVALID(_firstPts)) {
            _firstPts = pts;
        }
        
        if(CMTIME_IS_INVALID(_firstDts)) {
            _firstDts = dts;
        }
        
        CMSampleTimingInfo timingInfo = kCMTimingInfoInvalid;
        timingInfo.duration = dur;
        timingInfo.presentationTimeStamp = CMTimeSubtract(pts, _firstPts);
        timingInfo.decodeTimeStamp = CMTimeSubtract(dts, _firstDts);
        
        CMVideoFormatDescriptionRef videoInfo = NULL;
        CMVideoFormatDescriptionCreateForImageBuffer(NULL, buffer, &videoInfo);
        
        CVPixelBufferLockBaseAddress(buffer, 0);
        CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,buffer,true,NULL,NULL,videoInfo,&timingInfo,&newSampleBuffer);
        
        // the following line submits the new CMSampleBufferRef to the nanostreamAVC lib
        [self.myVideoOutput.sampleBufferDelegate captureOutput:self.myVideoOutput didOutputSampleBuffer:newSampleBuffer fromConnection:nil];
        
        CVPixelBufferUnlockBaseAddress(buffer, 0);
        
        CFRelease(videoInfo);
        CFRelease(newSampleBuffer);
    });
}

@end

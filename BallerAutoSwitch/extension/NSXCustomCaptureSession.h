#import <AVFoundation/AVFoundation.h>

@interface NSXCustomCaptureSession : AVCaptureSession

@property (nonatomic, strong) AVCaptureVideoDataOutput* myVideoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput* myAudioOutput;

-(id) init;

-(void) addInput:(AVCaptureInput *)input;
-(void) addOutput:(AVCaptureOutput *)output;

-(void) startRunning;
-(void) stopRunning;

-(void) supplyVideoBuffer:(CVImageBufferRef)buffer;
-(void) supplyVideoBuffer:(CVImageBufferRef)buffer withPts:(CMTime)pts withDts:(CMTime)dts andDuration:(CMTime)dur;

-(void) reset;

@end

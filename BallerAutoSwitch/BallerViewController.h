#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <GLKit/GLKit.h>

#import "nanostreamAVC.h"
#import "nanostreamAVCRtmpSourceCaptureSession.h"
#import "nanoLicenseConfig.h"

#import "NSXTimer.h"
#import "NSXCustomCaptureSession.h"

#import "RTSPPlayer.h"

@class RTSPPlayer;

@interface BallerViewController : UIViewController <nanostreamEventListener, RTSPPlayerDelegate>

{
    Boolean streamStarted; // false
    Boolean inBackground;
    
    
	float lastFrameTime;
}

@property (nonatomic, retain) IBOutlet UIView *mixedView;

@property (nonatomic, retain) IBOutlet UIImageView *imageViewLeft;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewRight;

@property (retain, nonatomic) IBOutlet UIImageView *processedViewLeft;
@property (retain, nonatomic) IBOutlet UIImageView *processedViewRight;


@property (retain, nonatomic) IBOutlet UILabel *motionLeft;
@property (retain, nonatomic) IBOutlet UILabel *motionRight;


@property (nonatomic, retain) IBOutlet UIImageView *imageViewBig;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewSmall;


@property (nonatomic, strong) AVCaptureSession *_session;
@property (nonatomic, strong) dispatch_queue_t _sessionQueue;
@property (nonatomic, strong) nanostreamAVC *stream;
@property (nonatomic, strong) NSXCustomCaptureSession *customSession;

@property (nonatomic, retain) IBOutlet UIButton *broadcastButton;
@property (nonatomic, retain) RTSPPlayer *video;
@property (nonatomic, retain) RTSPPlayer *video1;

@property (nonatomic) NSInteger counter;
@property (nonatomic) NSInteger selected;

- (void)playRTSPStreams;
- (IBAction)broadcastButtonAction:(id)sender;
- (IBAction)selectFirst;
- (IBAction)selectSecond;


-(void)activateBackground;
-(void)activateForeground;



@end

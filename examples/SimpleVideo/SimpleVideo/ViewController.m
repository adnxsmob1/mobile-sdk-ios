/*   Copyright 2017 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "ViewController.h"
#import "AVPlayerView.h"
#import "AdViewController.h"


@import AVFoundation;

#import <AppNexusSDK/AppNexusSDK.h>

NSString *const  videoContent  = @"https://acdn.adnxs.com/mobile/video_test/content/Scenario.mp4";

NSString *const placementId = @"9924001";

@interface ViewController ()<ANInstreamVideoAdLoadDelegate, ANInstreamVideoAdPlayDelegate>

@property(nonatomic, weak) IBOutlet AVPlayerView *videoView;


@property (weak, nonatomic) IBOutlet UITextView *logTextView;

/// Frame for video view in portrait mode.
@property(nonatomic, assign) CGRect portraitVideoViewFrame;

/// Frame for video player in fullscreen mode.
@property(nonatomic, assign) CGRect fullscreenVideoFrame;

@property (strong, nonatomic)  ANInstreamVideoAd  *videoAd;

@property (strong, nonatomic)  AVPlayer *videoContentPlayer;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic, assign) BOOL isvideoAdAvailable;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playButton.layer.zPosition = MAXFLOAT;
    
    self.isvideoAdAvailable = false;
    
    [ANLogManager setANLogLevel:ANLogLevelAll];
    
    [[ANSDKSettings sharedInstance] setHTTPSEnabled:false];
    
    // Fix iPhone issue of log text starting in the middle of the UITextView
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.portraitVideoViewFrame = self.videoView.frame;
    
    
    // Check orientation, set to fullscreen if we're in landscape
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        [self viewDidEnterLandscape];
    }
    [self setupContentPlayer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButton_Touch:(id)sender {
    self.playButton.hidden = true;
    
    [self.videoContentPlayer pause];
        self.isvideoAdAvailable = false;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AdViewController *adViewController = [storyboard instantiateViewControllerWithIdentifier:@"AdViewController"];
        
        [adViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        [adViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        
        
        [self presentViewController:adViewController animated:YES completion:nil];
    
}




- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            [self viewDidEnterPortrait];
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            [self viewDidEnterLandscape];
            break;
        case UIInterfaceOrientationUnknown:
            break;
    }
}


-(void) setupContentPlayer {
    NSURL *contentURL = [NSURL URLWithString:videoContent];
    self.videoContentPlayer = [AVPlayer playerWithURL:contentURL];
    [self.videoContentPlayer seekToTime:kCMTimeZero];
    [self.videoView setPlayer:self.videoContentPlayer];
    
    self.videoView.translatesAutoresizingMaskIntoConstraints = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.videoContentPlayer.currentItem];

}

- (void)viewDidEnterLandscape {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.fullscreenVideoFrame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    
    [self.videoView setFrame:self.fullscreenVideoFrame];
    
}

- (void)viewDidEnterPortrait {
    
    [self.videoView setFrame:self.portraitVideoViewFrame];
    
}

#pragma mark Utility methods

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    NSLog(@"finished playing content");
    //cleanup the player & start again
    self.videoContentPlayer = nil;
    [self setupContentPlayer];
    self.playButton.hidden = NO;
    self.isvideoAdAvailable = false;
}

- (void)logMessage:(NSString *)log {
    NSString *logString = [NSString stringWithFormat:@"%@\n", log];
    
    self.logTextView.text = [self.logTextView.text stringByAppendingString:logString];
    if (self.logTextView.text.length > 0) {
        NSRange bottom = NSMakeRange(self.logTextView.text.length - 1, 1);
        [self.logTextView scrollRangeToVisible:bottom];
    }
}

#pragma mark - ANInstreamVideoAdDelegate.

//----------------------------- -o-
- (void) adDidReceiveAd: (id<ANAdProtocol>)ad
{
    [self logMessage:@"adDidReceiveAd"];
    
    self.isvideoAdAvailable = true;

    
}

- (void)                ad: (id<ANAdProtocol>)ad
    requestFailedWithError: (NSError *)error
{
    [self logMessage:@"adRequestFailedWithError"];
    self.isvideoAdAvailable = false;
}

//----------------------------- -o-
- (void) adCompletedFirstQuartile:(id<ANAdProtocol>)ad
{
    [self logMessage:@"adCompletedFirstQuartile"];
}


//----------------------------- -o-
- (void) adCompletedMidQuartile:(id<ANAdProtocol>)ad
{
    [self logMessage:@"adCompletedMidQuartile"];
}


//----------------------------- -o-
- (void) adCompletedThirdQuartile:(id<ANAdProtocol>)ad
{
    [self logMessage:@"adCompletedThirdQuartile"];
}


//----------------------------- -o-
- (void) adWasClicked: (id<ANAdProtocol>)ad
{
    [self logMessage:@"adWasClicked"];
}

//----------------------------- -o-
-(void) adMute: (id<ANAdProtocol>)ad
    withStatus: (BOOL)muteStatus
{
    if(muteStatus == YES){
        [self logMessage:@"adMuteOn"];
       
    } else {
        [self logMessage:@"adMuteOff"];
        
    }
    
}

-(void) adDidComplete:(id<ANAdProtocol>)ad withState:(ANInstreamVideoPlaybackStateType)state{
    
    if(state == ANInstreamVideoPlaybackStateSkipped){
         [self logMessage:@"adWasSkipped"];
    }else if(state == ANInstreamVideoPlaybackStateError){
        [self logMessage:@"adplaybackFailedWithError"];
    }else if(state == ANInstreamVideoPlaybackStateCompleted){
        [self logMessage:@"adPlayCompleted"];
    }
    
    self.isvideoAdAvailable = false;
    
    [self.videoContentPlayer play];
    
    
}


@end

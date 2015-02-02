//
//  PlayerViewController.m
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import "PlayerViewController.h"
#import "LSPlaySliderView.h"
#import "LSPlayer.h"
#import "NSString+LSAdditions.h"

@interface PlayerViewController ()<LSPlayerDelegate>{
    UIBarButtonItem *_playItem;
    UIBarButtonItem *_pauseItem;
    UIBarButtonItem *_loadingItem;
}

@property (nonatomic, strong) LSPlayer *player;
@property (nonatomic, weak) LSPlaySliderView *playSliderView;
@property (nonatomic, weak) UIToolbar *playerControlsToolbar;
@property (nonatomic, assign) BOOL restorePlayStateAfterScrubbing;


@end




@implementation PlayerViewController


- (instancetype)initWithPlayer:(LSPlayer *)player{
    self = [super init];
    if(self){
        self.player = player;
        self.player.delegate = self;
    }
    return self;
}


- (void)loadView{
    [super loadView];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    LSPlaySliderView *playSliderView = [[LSPlaySliderView alloc] init];
    [self.view addSubview:playSliderView];
    self.playSliderView = playSliderView;

    UISlider *slider = playSliderView.sliderView;
    [slider addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
    
    UIToolbar *tool = [[UIToolbar alloc] init];
    [tool setTranslucent:YES];
    tool.opaque = YES;
    tool.backgroundColor = [UIColor clearColor];
    tool.clipsToBounds = YES;
    [tool setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [tool setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny];
    [self.view addSubview:tool];
    self.playerControlsToolbar = tool;
    
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1.0/[[UIScreen mainScreen] scale])];
    v.backgroundColor = [UIColor grayColor];
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:v];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updatePlayerControls];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    const CGFloat kPlayerControlsWidth = 40.0;
    
    CGSize rootSize = self.view.bounds.size;
    
    [self.playerControlsToolbar setFrame:CGRectMake(0.0, 0.0, kPlayerControlsWidth, rootSize.height)];
    [self.playSliderView setFrame:CGRectMake(CGRectGetMaxX(self.playerControlsToolbar.frame), 0, rootSize.width-CGRectGetMaxX(self.playerControlsToolbar.frame), rootSize.height)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PlayBack Controls

- (UIBarButtonItem *)playItem{
    if(_playItem==nil){
        _playItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(actionPlay:)];
    }
    return _playItem;
}

- (UIBarButtonItem *)pauseItem{
    if(_pauseItem==nil){
        _pauseItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(actionPause:)];
    }
    return _pauseItem;
}

- (UIBarButtonItem *)loadingItem{
    if(_loadingItem==nil){
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator startAnimating];
        _loadingItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];
    }
    return _loadingItem;
}

- (void)updatePlayerControls{
    if(self.player.fileURL){
        if(self.player.isCurrentItemReadyToPlay){
            switch (self.player.status) {
                case LSPlayerStatusPlaying:
                    [self.playerControlsToolbar setItems:@[self.pauseItem]];
                    break;
                case LSPlayerStatusPause:
                    [self.playerControlsToolbar setItems:@[self.playItem]];
                    break;
                default:
                    [self.playerControlsToolbar setItems:@[self.loadingItem]];
                    break;
            }
        }
        else{
            [self.playerControlsToolbar setItems:@[self.loadingItem]];
        }
    }
    else{
        [self.playerControlsToolbar setItems:nil];
    }
}

- (void)updatePlayerView{
    [self updatePlaybackProgress];
    [self syncScrubber];
    [self syncPlayClock];
    [self syncPreloadProgress];
    [self updatePlayerControls];
}

- (void)actionPlay:(id)sender{
    [self.player play];
}

- (void)actionPause:(id)sender{
    [self.player pause];
}

#pragma mark - Scrubber control

- (void)updatePlaybackProgress{
    if(self.playSliderView.sliderView){
        self.player.timeObservingPrecision = CGRectGetWidth([self.playSliderView.sliderView bounds]);
        NSError *err = nil;
        [self.player startTimeObserving:&err];
    }
}

- (void)syncScrubber{
    double duration = [self.player duration];
    if (isfinite(duration)) {
        float minValue = [self.playSliderView.sliderView minimumValue];
        float maxValue = [self.playSliderView.sliderView maximumValue];
        double time = self.player.currentTime;
        [self.playSliderView.sliderView setValue:(maxValue - minValue) * time / duration + minValue];
    }
    else{
        self.playSliderView.sliderView.value = 0.0;
    }
}

- (void)syncPlayClock{
    double duration = [self.player duration];
    if (isfinite(duration)) {
        double currentTime = floor(self.player.currentTime);
        double timeLeft = floor(duration - currentTime);
        if (currentTime <= 0) {
            currentTime = 0;
            timeLeft = floor(duration);
        }
        [self.playSliderView.leftLabel setText:[NSString stringWithFormat:@"%@", [NSString stringFormattedTimeFromSeconds:&currentTime]]];
        [self.playSliderView.rightLabel setText:[NSString stringWithFormat:@"-%@", [NSString stringFormattedTimeFromSeconds:&timeLeft]]];
    }
    else{
        [self.playSliderView.rightLabel setText:@"--:--"];
        [self.playSliderView.leftLabel setText:@"--:--"];
    }
}

- (void)syncPreloadProgress{
    float progress = [self.player preloadProgress];
    [self.playSliderView.progressView setProgress:progress animated:NO];
}

- (void)beginScrubbing:(id)sender{
    if([self.player isPlaying]){
        self.restorePlayStateAfterScrubbing = YES;
        [self.player pause];
    }
    
    [self.player stopTimeObserving];
}

- (void)scrub:(id)sender{
    UISlider* slider = sender;
    double duration = self.player.duration;
    if (isfinite(duration)) {
        double currentTime = floor(duration * slider.value);
        double timeLeft = floor(duration - currentTime);
        
        if (currentTime <= 0) {
            currentTime = 0;
            timeLeft = floor(duration);
        }
        
        [self.playSliderView.leftLabel setText:[NSString stringWithFormat:@"%@ ", [NSString stringFormattedTimeFromSeconds:&currentTime]]];
        [self.playSliderView.rightLabel setText:[NSString stringWithFormat:@"-%@", [NSString stringFormattedTimeFromSeconds:&timeLeft]]];
    }
}

- (void)endScrubbing:(id)sender{
    
    UISlider* slider = sender;
    double duration = self.player.duration;
    if (isfinite(duration)) {
        double currentTime = floor(duration * slider.value);
        double timeLeft = floor(duration - currentTime);
        
        if (currentTime <= 0) {
            currentTime = 0;
            timeLeft = floor(duration);
        }
        [self.player seekToTime:currentTime];
    }
    
    if (self.restorePlayStateAfterScrubbing){
        [self.player play];
    }
    
    [self.player startTimeObserving:nil];
}

- (void)enableScrubber{
    self.playSliderView.sliderView.enabled = YES;
    self.playSliderView.progressView.alpha = 1.0;
}

- (void)disableScrubber{
    self.playSliderView.sliderView.enabled = NO;
    self.playSliderView.progressView.progress = 0.0;
    self.playSliderView.progressView.alpha = 0.2;
}

#pragma mark - LSPlayerDelegate

- (void)player:(LSPlayer*)player didFailWithStatus:(LSPlayerFailedStatus)status error:(NSError *)error{
    [self updatePlayerView];
}

- (void)player:(LSPlayer*)player didChangeReadyToPlayStatus:(LSPlayerReadyToPlayStatus)status{
    [self updatePlayerView];
}

- (void)player:(LSPlayer*)player didChangeRate:(float)rate{
    [self updatePlayerControls];
}

- (void)player:(LSPlayer*)player didPreLoadCurrentItemWithProgress:(float)progress{
    [self syncPreloadProgress];
}

- (void)playerDidChangeCurrentItem:(LSPlayer*)player{
    [self updatePlayerView];
}

- (void)playerDidReachEnd:(LSPlayer*)player{
    [self updatePlayerView];
}

- (void)playerDidChangeScrubberTime:(LSPlayer*)player{
     [self syncScrubber];
}

- (void)playerDidChangeClockTime:(LSPlayer*)player{
    [self syncPlayClock];
}

@end

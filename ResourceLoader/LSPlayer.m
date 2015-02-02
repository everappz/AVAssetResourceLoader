//
//  Player.m
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import "LSPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "YDSession.h"
#import "NSObject+LSAdditions.h"
#import "LSFilePlayerResourceLoader.h"


NSString * const kStatusKey                     = @"status";
NSString * const kRateKey                       = @"rate";
NSString * const kCurrentItemKey                = @"currentItem";
NSString * const kLoadedTimeRanges              = @"loadedTimeRanges";

NSString * const LSPlayerErrorDomain            = @"LSPlayerErrorDomain";


NSString * const LSFileScheme = @"customscheme";


@interface LSPlayer()<LSFilePlayerResourceLoaderDelegate,AVAssetResourceLoaderDelegate>

@property (nonatomic,strong)YDSession *session;
@property (nonatomic,strong)NSURL *fileURL;

@property (nonatomic,strong)AVPlayer *player;

@property (nonatomic,strong)NSMutableDictionary *resourceLoaders;

@property (nonatomic,strong)id scrubberTimeObserver;
@property (nonatomic,strong)id clockTimeObserver;

@property (nonatomic,assign)BOOL pauseReasonForcePause;

@end




@implementation LSPlayer


- (instancetype)init{
    self = [super init];
    if(self){
        self.timeObservingPrecision = 0.0;
        self.resourceLoaders = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Player State Changing

- (void)play{
    [self performBlockOnMainThreadSync:^{
        if([self isPlaying]==NO){
            self.pauseReasonForcePause = NO;
            [self playAudio];
        }
    }];
}

- (void)pause{
    [self performBlockOnMainThreadSync:^{
        if([self isPlaying]){
            self.pauseReasonForcePause = YES;
            [self pauseAudio];
        }
    }];
}

- (void)stop{
    [self performBlockOnMainThreadSync:^{
        self.pauseReasonForcePause = YES;
        if([self isPlaying]){
            [self stopAudio];
        }
        [self cancelAllAndClearPlayer];
    }];
}

- (void)seekToTime:(NSTimeInterval)time{
    [self performBlockOnMainThreadSync:^{
        @try{[self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];}@catch (NSException *exc) {}
    }];
}

- (void)playAudio{
    self.player.rate = 1.0;
}

- (void)playAudioIfPossible{
    if (self.isPlaying==NO && self.pauseReasonForcePause==NO){
        [self playAudio];
    }
}

- (void)pauseAudio{
    [self.player pause];
}

- (void)stopAudio{
    [self.player pause];
}

#pragma mark - Player Items Switching

- (void)cancelAllAndClearPlayer{
    [self clearPlayer];
    [self cancelAllResourceLoaders];
}

- (void)fetchAndPlayFileAtURL:(NSURL *)fileURL session:(YDSession *)session{
    
    [self performBlockOnMainThreadSync:^{

        self.fileURL = fileURL;
        self.session = session;
        
        [self cancelAllAndClearPlayer];
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
        [asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
       
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        [self addObserversForPlayerItem:item];

        [self createPlayerWithItem:item];
        
        [self notifyDidChangeCurrentItem];
        
        [self playAudioIfPossible];
    }];
    
}

- (void)currentAVPlayerItemDidFailedWithError:(NSError *)error{
    [self notifyDidFailWithStatus:LSPlayerFailedCurrentItem error:error];
    [self stop];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification{
    [self playerDidReachEnd];
}

- (void)playerDidReachEnd{
    self.fileURL = nil;
    self.session = nil;
    [self stop];
    [self notifyDidReachEnd];
}

- (void)currentAVPlayerItemDidChange:(AVPlayerItem *)playerItem{
    [self notifyDidChangeCurrentItem];
}

#pragma mark - Call Back`s

- (void)notifyDidFailWithStatus:(NSInteger)status error:(NSError *)error{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(player:didFailWithStatus:error:)]){
            [self.delegate player:self didFailWithStatus:status error:error];
        }
    }];
}

- (void)notifyDidChangeReadyToPlayStatus:(NSInteger)status{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(player:didChangeReadyToPlayStatus:)]){
            [self.delegate player:self didChangeReadyToPlayStatus:status];
        }
    }];
}

- (void)notifyDidChangeRate:(float)rate{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(player:didChangeRate:)]){
            [self.delegate player:self didChangeRate:rate];
        }
    }];
}

- (void)notifyDidPreLoadCurrentItemWithProgress:(float)progress{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(player:didPreLoadCurrentItemWithProgress:)]){
            [self.delegate player:self didPreLoadCurrentItemWithProgress:progress];
        }
    }];
}

- (void)notifyDidChangeCurrentItem{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(playerDidChangeCurrentItem:)]){
            [self.delegate playerDidChangeCurrentItem:self];
        }
    }];
}

- (void)notifyDidReachEnd{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(playerDidReachEnd:)]){
            [self.delegate playerDidReachEnd:self];
        }
    }];
}

- (void)notifyDidChangeScrubberTime{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(playerDidChangeScrubberTime:)]){
            [self.delegate playerDidChangeScrubberTime:self];
        }
    }];
}

- (void)notifyDidChangeClockTime{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(playerDidChangeClockTime:)]){
            [self.delegate playerDidChangeClockTime:self];
        }
    }];
}

#pragma mark - Player Observers

- (void)startTimeObserving:(NSError **)error{
    if(self.player){
        [self addPlayerTimeObservers:error];
    }
}

- (void)stopTimeObserving{
    if(self.player){
        [self removePlayerTimeObservers];
    }
}

- (void)addPlayerTimeObservers:(NSError **)error{
    
    [self removePlayerTimeObservers];

    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)){
        if(error){
            *error = [self errorWithCode:LSPlayerErrorCodeUnknown description:nil];
        }
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (CMTIME_IS_INDEFINITE(playerDuration) || duration <= 0) {
        if(error){
            *error = [self errorWithCode:LSPlayerErrorCodeUnknown description:nil];
        }
        [self syncPlayClock];
        return;
    }
    
    float precision = self.timeObservingPrecision;
    
    if(precision>0){
        interval = 0.5f * duration / precision;
    }
    
    __weak typeof(self) weakSelf = self;
    self.scrubberTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                          queue:NULL
                                                                     usingBlock:^(CMTime time){
                                                                         [weakSelf syncScrubber];
                                                                     }];
    
    
    self.clockTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                                       queue:NULL
                                                                  usingBlock:^(CMTime time) {
                                                                      [weakSelf syncPlayClock];
                                                                  }];
}

- (void)removePlayerTimeObservers{
    if (self.scrubberTimeObserver){
        [self.player removeTimeObserver:self.scrubberTimeObserver];
        self.scrubberTimeObserver = nil;
    }
    if (self.clockTimeObserver){
        [self.player removeTimeObserver:self.clockTimeObserver];
        self.clockTimeObserver = nil;
    }
}

- (void)syncScrubber{
    [self notifyDidChangeScrubberTime];
}

- (void)syncPlayClock{
    [self notifyDidChangeClockTime];
}

- (void)addObserversForPlayer{
    if(self.player){
        [self.player addObserver:self
                      forKeyPath:kCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:NULL];
        [self.player addObserver:self
                      forKeyPath:kStatusKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:NULL];
        [self.player addObserver:self
                      forKeyPath:kRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:NULL];
    }
}

- (void)removeObserversFromPlayer{
    if(self.player){
        [self.player removeObserver:self forKeyPath:kCurrentItemKey];
        [self.player removeObserver:self forKeyPath:kRateKey];
        [self.player removeObserver:self forKeyPath:kStatusKey];
        [self removePlayerTimeObservers];
    }
}

#pragma mark - Player Create/Destroy

- (void)createPlayerWithItem:(AVPlayerItem *)playerItem{
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    [self addObserversForPlayer];
}

- (void)clearPlayer{
    [self stopAudio];
    [self removeObserversFromPlayer];
    [self removeObserversFromPlayerItem:self.player.currentItem];
    self.player = nil;
    self.pauseReasonForcePause = NO;
}

#pragma mark - Player Info

- (NSTimeInterval)duration{
    return CMTimeGetSeconds([self playerItemDuration]);
}

- (NSTimeInterval)currentTime{
    return CMTimeGetSeconds([self.player currentTime]);
}

- (BOOL)isPlaying{
    return self.player.rate != 0.f;
}

- (BOOL)isCurrentItemReadyToPlay{
    return (self.player.currentItem.status==AVPlayerItemStatusReadyToPlay);
}

- (float)rate{
    return self.player.rate;
}

- (float)preloadProgress{
    float progress = 0.0;
    if ([self.player currentItem].status == AVPlayerItemStatusReadyToPlay){
        float durationTime = CMTimeGetSeconds([self playerItemDuration]);
        float bufferTime = [self playerItemAvailableDuration];
        if(durationTime>0.0){
            progress = bufferTime/durationTime;
        }
    }
    return progress;
}

- (LSPlayerStatus)status{
    if ([self isPlaying]){
        return LSPlayerStatusPlaying;
    }
    else if (self.pauseReasonForcePause){
        return LSPlayerStatusPause;
    }
    else{
        return LSPlayerStatusUnknown;
    }
}

#pragma mark - Player Item

- (CMTime)playerItemDuration{
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return([playerItem duration]);
    }
    return(kCMTimeInvalid);
}

- (double)playerItemAvailableDuration{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    if ([loadedTimeRanges count] > 0) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        double startSeconds = CMTimeGetSeconds(timeRange.start);
        double durationSeconds = CMTimeGetSeconds(timeRange.duration);
        return (startSeconds + durationSeconds);
    } else {
        return 0.0f;
    }
}

- (void)addObserversForPlayerItem:(AVPlayerItem *)item{
    if(item){
        [item addObserver:self
               forKeyPath:kStatusKey
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        
        [item addObserver:self
               forKeyPath:kLoadedTimeRanges
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:item];
    }
}

- (void)removeObserversFromPlayerItem:(AVPlayerItem *)item{
    if(item){
        [item removeObserver:self forKeyPath:kStatusKey];
        [item removeObserver:self forKeyPath:kLoadedTimeRanges];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:item];
    }
}


#pragma mark - Errors

- (NSError *)errorWithCode:(LSPlayerErrorCode)code description:(NSString *)errorDescription{
    NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
    if(errorDescription){
        [errorDict setObject:errorDescription forKey:NSLocalizedDescriptionKey];
    }
    NSError *error = [NSError errorWithDomain:LSPlayerErrorDomain code:code userInfo:errorDict];
    return error;
}

- (NSError *)errorWithCode:(LSPlayerErrorCode)code{
    return [self errorWithCode:code description:nil];
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString*)path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context{
    
    if(object==self.player){
        if ([path isEqualToString:kRateKey]){
            float newRate = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            BOOL willPlay = (newRate!= 0.f);
            if(willPlay){
                [self addPlayerTimeObservers:nil];
            }
            [self notifyDidChangeRate:newRate];
        }
        else if ([path isEqualToString:kCurrentItemKey]){
            
            AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
            AVPlayerItem *currentAVPlayerItem = newPlayerItem;
            
            if (newPlayerItem == (id)[NSNull null]){
                currentAVPlayerItem = nil;
                [self removePlayerTimeObservers];
            }
            
            BOOL failed = (newPlayerItem != (id)[NSNull null] && newPlayerItem.status==AVPlayerStatusFailed);
            [self currentAVPlayerItemDidChange:currentAVPlayerItem];
            if(failed){
                [self currentAVPlayerItemDidFailedWithError:currentAVPlayerItem.error];
            }
        }
        else if ([path isEqualToString:kStatusKey]){
            if (self.player.status == AVPlayerStatusReadyToPlay) {
                [self notifyDidChangeReadyToPlayStatus:LSPlayerReadyToPlayPlayer];
                [self playAudioIfPossible];
            } else if (self.player.status == AVPlayerStatusFailed) {
                [self stop];
                [self notifyDidFailWithStatus:LSPlayerFailedPlayer error:self.player.error];
            }
        }
    }
    else if(object==self.player.currentItem){
        
        AVPlayerItem *currentPlayerItem = (AVPlayerItem *)object;
        
        if ([path isEqualToString:kStatusKey]){
            
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            
            if(status==AVPlayerStatusReadyToPlay){
                [self addPlayerTimeObservers:nil];
                [self notifyDidChangeReadyToPlayStatus:LSPlayerReadyToPlayCurrentItem];
                [self playAudioIfPossible];
                
            }
            else if(status==AVPlayerStatusFailed){
                [self currentAVPlayerItemDidFailedWithError:currentPlayerItem.error];
            }
        }
        else if ([path isEqualToString:kLoadedTimeRanges]){
            NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
            if (timeRanges && [timeRanges count]) {
                [self notifyDidPreLoadCurrentItemWithProgress:[self preloadProgress]];
            }
        }
    }
}


#pragma mark - Player Items Checking

+ (NSArray *)playerSupportedMimeTypes{
    return [AVURLAsset audiovisualMIMETypes];
}

+ (BOOL)canPlayFileWithType:(NSString *)fileMimeType{
    for(NSString *mime in [[self class] playerSupportedMimeTypes]){
        if([mime isEqualToString:fileMimeType]){
            return YES;
        }
    }
    return NO;
}


#pragma mark - AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSURL *resourceURL = [loadingRequest.request URL];
    if([resourceURL.scheme isEqualToString:LSFileScheme]){
        LSFilePlayerResourceLoader *loader = [self resourceLoaderForRequest:loadingRequest];
        if(loader==nil){
            loader = [[LSFilePlayerResourceLoader alloc] initWithResourceURL:resourceURL session:self.session];
            loader.delegate = self;
            [self.resourceLoaders setObject:loader forKey:[self keyForResourceLoaderWithURL:resourceURL]];
        }
        [loader addRequest:loadingRequest];
        return YES;
    }
    return NO;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    LSFilePlayerResourceLoader *loader = [self resourceLoaderForRequest:loadingRequest];
    [loader removeRequest:loadingRequest];
}

#pragma mark - LSFilePlayerResourceLoader

- (void)removeResourceLoader:(LSFilePlayerResourceLoader *)resourceLoader{
    id <NSCopying> requestKey = [self keyForResourceLoaderWithURL:resourceLoader.resourceURL];
    if(requestKey){
        [self.resourceLoaders removeObjectForKey:requestKey];
    }
}

- (void)cancelAndRemoveResourceLoaderForURL:(NSURL *)resourceURL{
    id <NSCopying> requestKey = [self keyForResourceLoaderWithURL:resourceURL];
    LSFilePlayerResourceLoader *loader = [self.resourceLoaders objectForKey:requestKey];
    [self removeResourceLoader:loader];
    [loader cancel];
}

- (void)cancelAllResourceLoaders{
    NSArray *items = [self.resourceLoaders allValues];
    [self.resourceLoaders removeAllObjects];
    for(LSFilePlayerResourceLoader *loader in items){
        [loader cancel];
    }
}

- (id<NSCopying>)keyForResourceLoaderWithURL:(NSURL *)requestURL{
    if([requestURL.scheme isEqualToString:LSFileScheme]){
        NSString *s = requestURL.absoluteString;
        return s;
    }
    return nil;
}

- (LSFilePlayerResourceLoader *)resourceLoaderForRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSURL *interceptedURL = [loadingRequest.request URL];
    if([interceptedURL.scheme isEqualToString:LSFileScheme]){
        id <NSCopying> requestKey = [self keyForResourceLoaderWithURL:[loadingRequest.request URL]];
        LSFilePlayerResourceLoader *loader = [self.resourceLoaders objectForKey:requestKey];
        return loader;
    }
    return nil;
}

- (void)filePlayerResourceLoader:(LSFilePlayerResourceLoader *)resourceLoader didFailWithError:(NSError *)error{
    [self cancelAndRemoveResourceLoaderForURL:resourceLoader.resourceURL];
}

@end

//
//  Player.h
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LSPlayerStatusUnknown = -1,
    LSPlayerStatusPlaying,
    LSPlayerStatusPause,
} LSPlayerStatus;

typedef enum {
    LSPlayerErrorCodeUnknown=-1,
} LSPlayerErrorCode;

typedef NS_ENUM(NSUInteger, LSPlayerReadyToPlayStatus) {
    LSPlayerReadyToPlayPlayer = 200,
    LSPlayerReadyToPlayCurrentItem,
};

typedef NS_ENUM(NSUInteger, LSPlayerFailedStatus) {
    LSPlayerFailedPlayer = 500,
    LSPlayerFailedCurrentItem,
};

extern NSString * const LSPlayerErrorDomain;
extern NSString * const LSFileScheme;

@protocol LSPlayerDelegate;
@class YDSession;

@interface LSPlayer : NSObject

@property (nonatomic,readonly)BOOL isPlaying;
@property (nonatomic,readonly)LSPlayerStatus status;
@property (nonatomic,readonly,strong)NSURL *fileURL;
@property (nonatomic,readonly)float rate;
@property (nonatomic,readonly)float preloadProgress;
@property (nonatomic,readonly)BOOL isCurrentItemReadyToPlay;
@property (nonatomic,readonly)NSTimeInterval duration;
@property (nonatomic,readonly)NSTimeInterval currentTime;
@property (nonatomic,assign)float timeObservingPrecision;
@property (nonatomic,weak)id<LSPlayerDelegate>delegate;

- (void)fetchAndPlayFileAtURL:(NSURL *)fileURL session:(YDSession *)session;

- (void)play;
- (void)pause;
- (void)stop;

- (void)seekToTime:(NSTimeInterval)time;

- (void)startTimeObserving:(NSError **)error;
- (void)stopTimeObserving;

+ (BOOL)canPlayFileWithType:(NSString *)fileMimeType;

@end

@protocol LSPlayerDelegate <NSObject>

- (void)player:(LSPlayer*)player didFailWithStatus:(LSPlayerFailedStatus)status error:(NSError *)error;
- (void)player:(LSPlayer*)player didChangeReadyToPlayStatus:(LSPlayerReadyToPlayStatus)status;

- (void)player:(LSPlayer*)player didChangeRate:(float)rate;

- (void)player:(LSPlayer*)player didPreLoadCurrentItemWithProgress:(float)progress;
- (void)playerDidChangeCurrentItem:(LSPlayer*)player;
- (void)playerDidReachEnd:(LSPlayer*)player;

- (void)playerDidChangeScrubberTime:(LSPlayer*)player;
- (void)playerDidChangeClockTime:(LSPlayer*)player;

@end


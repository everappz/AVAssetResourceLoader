//
//  LSFilePlayerResourceLoader.h
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import <AVFoundation/AVFoundation.h>

@class YDSession;
@protocol LSFilePlayerResourceLoaderDelegate;


@interface LSFilePlayerResourceLoader : NSObject

@property (nonatomic,readonly,strong)NSURL *resourceURL;

@property (nonatomic,readonly)NSArray *requests;

@property (nonatomic,readonly,strong)YDSession *session;

@property (nonatomic,readonly,assign)BOOL isCancelled;

@property (nonatomic,weak)id<LSFilePlayerResourceLoaderDelegate> delegate;


- (instancetype)initWithResourceURL:(NSURL *)url session:(YDSession *)session;

- (void)addRequest:(AVAssetResourceLoadingRequest *)loadingRequest;

- (void)removeRequest:(AVAssetResourceLoadingRequest *)loadingRequest;

- (void)cancel;

@end



@protocol LSFilePlayerResourceLoaderDelegate <NSObject>

@optional

- (void)filePlayerResourceLoader:(LSFilePlayerResourceLoader *)resourceLoader didFailWithError:(NSError *)error;

- (void)filePlayerResourceLoader:(LSFilePlayerResourceLoader *)resourceLoader didLoadResource:(NSURL *)resourceURL;

@end

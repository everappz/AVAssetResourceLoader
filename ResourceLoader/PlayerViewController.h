//
//  PlayerViewController.h
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import <UIKit/UIKit.h>

@class LSPlayer;

@interface PlayerViewController : UIViewController

- (instancetype)initWithPlayer:(LSPlayer *)player;

@property (nonatomic, readonly, strong) LSPlayer *player;

@end

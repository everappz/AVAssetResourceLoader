//
//  FilesListViewController.h
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import <UIKit/UIKit.h>

@class YDSession;
@protocol FilesListViewControllerDelegate;

@interface FilesListViewController : UIViewController

- (instancetype)initWithSession:(YDSession *)session path:(NSString *)path;

@property (nonatomic, readonly, copy) NSString *path;
@property (nonatomic, readonly, copy) NSArray *entries;
@property (nonatomic, readonly, strong) YDSession *session;
@property (nonatomic, weak)id<FilesListViewControllerDelegate> delegate;

@end


@protocol FilesListViewControllerDelegate <NSObject>

@optional

- (void)filesListController:(FilesListViewController *)vc didSelectFileAtPath:(NSString *)filePath;

@end
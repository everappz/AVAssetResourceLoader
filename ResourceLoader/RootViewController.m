//
//  RootViewController.m
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import "RootViewController.h"
#import "PlayerViewController.h"
#import "FilesListViewController.h"
#import "LSPlayer.h"
#import "YDSession.h"
#import "YOAuth2ViewController.h"
#import "NSString+LSAdditions.h"


@interface RootViewController ()<YDSessionDelegate,YOAuth2Delegate,FilesListViewControllerDelegate>{
    dispatch_queue_t _yandex_queue;
}

@property (nonatomic,weak)UIView *filesListView;
@property (nonatomic,weak)UIView *playerView;
@property (nonatomic,strong)LSPlayer *player;
@property (nonatomic,strong)YDSession *session;
@property (nonatomic,strong)UINavigationController *filesListNavigationController;
@property (nonatomic,strong)FilesListViewController *filesListViewController;
@property (nonatomic,strong)PlayerViewController *playerViewController;


@end


@implementation RootViewController


- (instancetype)init{
    self = [super init];
    if(self){
        
        _yandex_queue = dispatch_queue_create("com.leshko.yandex.queue", NULL);
        
        self.session = [[YDSession alloc] initWithDelegate:self callBackQueue:_yandex_queue];
        
        FilesListViewController *listVC = [[FilesListViewController alloc] initWithSession:self.session path:@"/"];
        listVC.delegate = self;
        listVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                                                         style:UIBarButtonItemStyleBordered
                                                                                        target:self
                                                                                        action:@selector(authenticate:)];
        
        self.filesListViewController = listVC;
        
        self.filesListNavigationController = [[UINavigationController alloc] initWithRootViewController:listVC];
        
        self.player = [[LSPlayer alloc] init];
        self.playerViewController = [[PlayerViewController alloc] initWithPlayer:self.player];
        
    }
    return self;
}

#pragma mark - Authentication

- (void)authenticate:(id)sender{
    [self authenticateAnimated:YES];
}

- (void)cancelAuth:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)authenticateAnimated:(BOOL)animated{
    if (!self.session.authenticated) {
        YOAuth2ViewController *authVC = [[YOAuth2ViewController alloc] initWithDelegate:self];
        authVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                                    style:UIBarButtonItemStyleBordered
                                                                                   target:self
                                                                                   action:@selector(cancelAuth:)];
        UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:authVC];
        [self presentViewController:navC
                                 animated:animated
                               completion:nil];
    }
}

#pragma mark - YDSessionDelegate

- (NSString *)userAgent{
    return @"asset-resource-loader-example-ios";
}


#pragma mark - YOAuth2Delegate

- (NSString *)clientID{
    return @"63330c6c6d094dfd95bf5575d7c19e5e";
}

- (NSString *)redirectURL{
    return @"https://oauth.yandex.ru/verification_code?ncrnd=7884";
}

- (void)OAuthLoginSucceededWithToken:(NSString *)token{
    self.session.OAuthToken = token;
    self.filesListViewController.navigationItem.rightBarButtonItem = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)OAuthLoginFailedWithError:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - FilesListViewController Delegate

- (void)filesListController:(FilesListViewController *)vc didSelectFileAtPath:(NSString *)filePath{
    if([LSPlayer canPlayFileWithType:filePath.mimeTypeForPathExtension]){
        NSURL *fileURL = [[NSURL alloc] initWithScheme:LSFileScheme host:@"yandex.disk" path:filePath];
        [self.player fetchAndPlayFileAtURL:fileURL session:self.session];
    }
}

#pragma mark - UIView

- (void)loadView{
    [super loadView];
    
    UIView *v = [[UIView alloc] init];
    [self.view addSubview:v];
    self.filesListView = v;
    
    v = [[UIView alloc] init];
    [self.view addSubview:v];
    self.playerView = v;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.filesListNavigationController willMoveToParentViewController:self];
    [self addChildViewController:self.filesListNavigationController];
    self.filesListNavigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.filesListNavigationController.view setFrame:self.filesListView.bounds];
    [self.filesListView addSubview:self.filesListNavigationController.view];
    [self.filesListNavigationController didMoveToParentViewController:self];
    
    [self.playerViewController willMoveToParentViewController:self];
    [self addChildViewController:self.playerViewController];
    self.playerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.playerViewController.view setFrame:self.playerView.bounds];
    [self.playerView addSubview:self.playerViewController.view];
    [self.playerViewController didMoveToParentViewController:self];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    const CGFloat kPlayerViewHeight = 50.0;
    
    CGSize rootSize = self.view.bounds.size;
    
    [self.filesListView setFrame:CGRectMake(0, 0, rootSize.width, rootSize.height-kPlayerViewHeight)];
    [self.playerView setFrame:CGRectMake(0, CGRectGetMaxY(self.filesListView.frame), rootSize.width, kPlayerViewHeight)];
}

@end

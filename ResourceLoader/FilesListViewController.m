//
//  FilesListViewController.m
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import "FilesListViewController.h"
#import "YDSession.h"
#import "YDItemStat.h"
#import "LSPlayer.h"
#import "NSString+LSAdditions.h"
#import "UIImage+LSAdditions.h"





@interface FilesListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSArray *entries;
@property (nonatomic, strong) YDSession *session;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;

@end



@implementation FilesListViewController

- (instancetype)initWithSession:(YDSession *)session path:(NSString *)path{
    self = [super init];
    if(self){
        self.session = session;
        self.path = path;
    }
    return self;
}

- (BOOL)isCurrentPathRoot{
    return [self.path.lastPathComponent isEqualToString:@"/"];
}

- (void) loadDir{
    [self.activityIndicator startAnimating];
    [self.session fetchDirectoryContentsAtPath:self.path completion:^(NSError *err, NSArray *list) {
        if (!err) {
            self.entries = list;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.activityIndicator stopAnimating];
            });
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:err.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
}

- (BOOL)canPlayItem:(YDItemStat *)entry{
    return entry.isFile && [LSPlayer canPlayFileWithType:entry.path.mimeTypeForPathExtension];
}

#pragma mark - UIViewController methods

- (void)loadView{
    [super loadView];
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds];
    table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    self.tableView = table;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    activity.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    activity.hidesWhenStopped = YES;
    [self.view addSubview:activity];
    self.activityIndicator = activity;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = self.isCurrentPathRoot ? @"Yandex.Disk" : self.path.lastPathComponent;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.entries==nil && self.session.authenticated) {
        [self loadDir];
    }
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    YDItemStat *entry = self.entries[indexPath.row];
    cell.textLabel.text = entry.name;
    cell.detailTextLabel.text = entry.mimeType;
    
    if (entry.isDirectory) {
        cell.imageView.image = [UIImage templateImageNamed:@"folder"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (entry.isFile) {
        if([self canPlayItem:entry]){
            cell.imageView.image = [UIImage templateImageNamed:@"music_note"];
        }
        else{
            cell.imageView.image = [UIImage templateImageNamed:@"file"];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YDItemStat *item = self.entries[indexPath.row];
    NSString *nextpath = [self.path stringByAppendingPathComponent:item.name];
    
    if (item.isDirectory) {
        FilesListViewController *nextDirController = [[FilesListViewController alloc] initWithSession:self.session path:nextpath];
        nextDirController.delegate = self.delegate;
        [self.navigationController pushViewController:nextDirController animated:YES];
    }
    else if([self.delegate respondsToSelector:@selector(filesListController:didSelectFileAtPath:)]){
        [self.delegate filesListController:self didSelectFileAtPath:item.path];
    }
}

@end

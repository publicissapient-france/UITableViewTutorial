//
//  GHRepositoryTableViewController.m
//  UITableViewTutorial
//
//  Created by Alexis Kinsella on 30/04/13.
//  Copyright (c) 2013 Xebia. All rights reserved.
//

#import "GHRepositoryTableViewController.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "XBLogging.h"
#import "MBProgressHUD.h"
#import "JSONKit.h"
#import "GHRepository.h"
#import "UIImageView+AFNetworking.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "DCKeyValueObjectMapping.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface GHRepositoryTableViewController ()

@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIImage *defaultAvatarImage;
@property (nonatomic, strong) NSString *nextPageURL;

@end

@implementation GHRepositoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.defaultAvatarImage = [UIImage imageNamed:@"github"];
    [self setupPullToRefresh];
    [self setupInfiniteScroll];
    [self initProgressHUD];
    [self loadDataWithCallback:^{}];
}

- (void)setupPullToRefresh {
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        weakSelf.nextPageURL = nil;
        weakSelf.dataSource = nil;
        [weakSelf loadDataWithCallback:^{
            [weakSelf.tableView.pullToRefreshView stopAnimating];
            [weakSelf.tableView reloadData];
        }];
    }];
}

- (void)setupInfiniteScroll {
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        if (weakSelf.nextPageURL) {
            [weakSelf loadDataWithCallback:^{
                [weakSelf.tableView.infiniteScrollingView stopAnimating];
                [weakSelf.tableView reloadData];
            }];
        }
        else {
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        }
    }];
}

- (void)loadDataWithCallback:(void(^)())callback {
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://api.github.com"]];
    NSString *path = self.nextPageURL ? self.nextPageURL : @"/orgs/facebook/repos";
    NSURLRequest *urlRequest = [httpClient requestWithMethod:@"GET" path:path parameters:nil];

    [self showProgressHUDWithMessage:NSLocalizedString(@"Chargement des données", nil) graceTime:0.5];

    XBLogInfo(@"[GET] Requesting JSON payload at: %@", urlRequest.URL);
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self tryFindNextPageUrl: operation.response];
        [self buildDataSourceFromResponseData:responseObject];

        [self.tableView reloadData];
        [self dismissProgressHUD];
        if (callback) {
            callback();
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        XBLogWarn(@"Error: %@", error);

        self.dataSource = [NSMutableArray array];
        [self.tableView reloadData];
        [self showErrorProgressHUDWithMessage:NSLocalizedString(@"Erreur de chargement des données !", nil) afterDelay:0.5];

        if (callback) {
            callback();
        }
    }];

    [operation start];
}

- (void)buildDataSourceFromResponseData:(id)responseObject {
    NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    NSArray *json = [jsonString objectFromJSONString];

    DCParserConfiguration *parserConfiguration = [DCParserConfiguration configuration];
    parserConfiguration.datePattern = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass: GHRepository.class andConfiguration:parserConfiguration];
    NSMutableArray *resultArray = [[parser parseArray:json] mutableCopy];

    if (self.dataSource) {
        [self.dataSource addObjectsFromArray:resultArray];
    }
    else {
        self.dataSource =  resultArray;
    }
}

- (void)tryFindNextPageUrl:(NSHTTPURLResponse *)response {
    NSString *linkHeader = response.allHeaderFields[@"Link"];
    if (linkHeader) {
        NSArray *links = [linkHeader componentsSeparatedByString:@","];
        
        NSString * __block nextPageURL = nil;
        [links enumerateObjectsUsingBlock:^(NSString *link, NSUInteger idx, BOOL *stop) {
            NSArray *linkParts = [link componentsSeparatedByString:@";"];
            NSString *rel = [linkParts[1] componentsSeparatedByString:@"\""][1];
            if ([rel isEqualToString:@"next"]) {
                nextPageURL = [linkParts[0] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
                *stop = YES;
            }
        }];
        self.nextPageURL = [nextPageURL substringFromIndex:@"https://api.github.com".length];
    }
    else {
        self.nextPageURL = nil;
    }
}

#pragma mark - Progress HUD

- (void)initProgressHUD {
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
}

- (void)showProgressHUDWithMessage:(NSString *)message graceTime:(float)graceTime {
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.labelText = NSLocalizedString(message, message);
    self.progressHUD.graceTime = graceTime;
    self.progressHUD.taskInProgress = YES;
    [self.navigationController.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
}

- (void)showErrorProgressHUDWithMessage:(NSString *)errorMessage afterDelay:(float)delay {
    self.progressHUD.mode = MBProgressHUDModeText;
    self.progressHUD.labelText = errorMessage;
    [self.progressHUD hide:YES afterDelay:delay];
    self.progressHUD.taskInProgress = NO;
    [self.navigationController.view addSubview:self.progressHUD];
}

- (void)dismissProgressHUD {
    self.progressHUD.taskInProgress = NO;
    [self.progressHUD hide:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RepositoryCell";
    UITableViewCell *repositoryCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    GHRepository *repository = self.dataSource[(NSUInteger) indexPath.row];

    repositoryCell.textLabel.text = repository.name;
    repositoryCell.detailTextLabel.text = repository.description_;

    [repositoryCell.imageView setImageWithURL:repository.owner.avatarImageUrl placeholderImage:self.defaultAvatarImage];

    return repositoryCell;
}

@end

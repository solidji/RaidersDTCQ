//
//  PersonalViewController.m
//  AppGame
//
//  Created by 计 炜 on 13-5-15.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "PersonalViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"

#import "ArticleItem.h"

#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"
#import "RSSParser.h"
#import "RSSItem.h"
#import "SVWebViewController.h"

@interface PersonalViewController ()
- (void)revealSidebar;
@end

@implementation PersonalViewController

@synthesize headerView;
@synthesize pullToRefreshTableView,dUser;
@synthesize following,follower,active;

#pragma mark - View lifecycle
- (id)initWithTitle:(NSString *)title withUser:(NSNumber *)userID withRevealBlock:(PersonalRevealBlock)revealBlock {
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = title;
        self.dUser.userID = userID;
        _revealBlock = [revealBlock copy];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 49, 25);
        [leftButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setShowsTouchWhenHighlighted:YES];
        [leftButton addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *temporaryLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        temporaryLeftBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.leftBarButtonItem = temporaryLeftBarButtonItem;
    }
    alerViewManager = [[AlerViewManager alloc] init];
    ifNeedFristLoading = YES;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.pullToRefreshTableView addParallelViewWithUIView:self.headerView withDisplayRadio:0.8 headerViewStyle:ZGScrollViewStyleCutOffAtMax];
    //By default, displayRadio is 0.5
    //By default, cutOffAtMax is set to NO
    //Set cutOffAtMax to YES to stop the scrolling when it hits the top.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

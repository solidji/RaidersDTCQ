//
//  VideoViewController.h
//  RaidersDOTA
//
//  Created by 计 炜 on 13-7-19.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayerKit.h"
#import "PullToRefreshTableView.h"
#import "AlerViewManager.h"

@interface VideoViewController : UIViewController <VideoPlayerDelegate,UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,UIGestureRecognizerDelegate> {
    NSMutableArray *comments;//数据源
    PullToRefreshTableView *pullToRefreshTableView;
    
    AlerViewManager *alerViewManager;
    NSInteger start;
    NSInteger receiveMember;
}

@property (nonatomic, strong) PullToRefreshTableView * pullToRefreshTableView;
@property (strong, nonatomic) NSMutableArray *comments;

- (id)initWithTitle:(NSString *)title withFrame:(CGRect)frame;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;

@end

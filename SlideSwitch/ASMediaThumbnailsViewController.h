//
//  ASMediaThumbnailsViewController.h
//  RaidersDOTA
//
//  Created by 计 炜 on 13-7-11.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASMediaFocusManager.h"
#import "PullToRefreshTableView.h"
#import "AlerViewManager.h"

@interface ASMediaThumbnailsViewController : UIViewController <ASMediasFocusDelegate, UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate>
{
    NSMutableArray *imageViews;
    ASMediaFocusManager *photoFocusManager;
    UIScrollView *scrollView;
    UIView *contentView;
    
    NSMutableArray *comments;//数据源
    PullToRefreshTableView *pullToRefreshTableView;
    AlerViewManager *alerViewManager;
    NSInteger start;
    NSInteger receiveMember;
}

@property (strong, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) ASMediaFocusManager *photoFocusManager;
@property (strong, nonatomic)  UIScrollView *scrollView;
@property (strong, nonatomic)  UIView *contentView;
@property (strong, strong)  PullToRefreshTableView *pullToRefreshTableView;
@property (strong, nonatomic) NSMutableArray *comments;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;
@end

//
//  ArticleListViewController.h
//  AppGame
//
//  Created by 计 炜 on 13-3-2.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "PullToRefreshTableView.h"
#import "AlerViewManager.h"

typedef void (^MyRevealBlock)();
@interface ArticleListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ScrollPageDataSource> {
    NSMutableArray *articles;//数据源
    NSMutableArray *promos;//促销数据源
    //UIActivityIndicatorView *indicator;
    PullToRefreshTableView *pullToRefreshTableView;
    TableHeaderView *headerView;
    
    AlerViewManager *alerViewManager;
    NSString *webURL;
    NSInteger start;
    NSInteger receiveMember;
    BOOL ifNeedFristLoading;
@private
	MyRevealBlock _revealBlock;
}

@property (nonatomic, copy) NSString *webURL;
@property (nonatomic, strong) PullToRefreshTableView * pullToRefreshTableView;
@property (nonatomic, strong) TableHeaderView *headerView;
@property (strong, nonatomic) NSMutableArray *articles,*promos;

- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url withRevealBlock:(MyRevealBlock)revealBlock;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;

@end

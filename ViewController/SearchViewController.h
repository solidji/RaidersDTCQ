//
//  SearchViewController.h
//  RaidersDOTA
//
//  Created by 计 炜 on 13-7-22.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableView.h"
#import "AlerViewManager.h"
#import "TFIndicatorView.h"

@interface SearchViewController : UIViewController<UIScrollViewDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
    NSString *searchStr;
    UISearchBar *_searchBar;
    PullToRefreshTableView *searchView;
    NSMutableArray *articles;//搜索结果,文章数据源
    AlerViewManager *alerViewManager;
    TFIndicatorView *etActivity;
    NSInteger start;
    NSInteger receiveMember;
    BOOL ifNeedFristLoading;
}

@property (nonatomic, copy) NSString *searchStr;
@property (nonatomic, strong) PullToRefreshTableView *searchView;
@property (strong, nonatomic) NSMutableArray *articles;

- (id)initWithTitle:(NSString *)title withFrame:(CGRect)frame;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;

@end

//
//  PersonalViewController.h
//  AppGame
//
//  Created by 计 炜 on 13-5-15.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "PullToRefreshTableView.h"
#import "AlerViewManager.h"

typedef void (^PersonalRevealBlock)();

@interface PersonalViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, ScrollPageDataSource> {
    NSMutableArray *promos;//促销数据源
    NSMutableArray *historys;//搜索历史
    NSMutableArray *hotkeys;//热门搜索
    NSMutableArray *recommends;//根据输入推荐的游戏名关键词
    NSMutableArray *itunesAppnames;//从苹果商店获取的游戏名数据库
    NSMutableArray *articles;//文章数据源
    //UIActivityIndicatorView *indicator;
    
    AlerViewManager *alerViewManager;
    NSString *webURL;
    NSInteger start;
    NSInteger receiveMember;
    BOOL ifNeedFristLoading;
    NSString *searchStr;
    UISearchBar *_searchBar;
    TableHeaderView *headerView;

    PullToRefreshTableView *pullToRefreshTableView, *recommendsTableView, *hotkeysTableView, *historysTableView;
    
@private
	PersonalRevealBlock _revealBlock;
}

@property (nonatomic, copy) NSString *webURL;

@property (nonatomic, strong) TableHeaderView *headerView;

@property (nonatomic, strong) PullToRefreshTableView *pullToRefreshTableView, *recommendsTableView, *hotkeysTableView, *historysTableView;
@property (strong, nonatomic) NSMutableArray *articles;
@property (strong, nonatomic) NSMutableArray *promos;
@property (strong, nonatomic) NSMutableArray *historys;
@property (strong, nonatomic) NSMutableArray *hotkeys;
@property (strong, nonatomic) NSMutableArray *recommends;
@property (strong, nonatomic) NSMutableArray *itunesAppnames;
@property (nonatomic, copy)NSString *searchStr;

- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url withRevealBlock:(PersonalRevealBlock)revealBlock;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;

@end

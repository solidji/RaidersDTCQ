//
//  ActivityViewController.h
//  AppGame
//
//  Created by 计 炜 on 13-5-19.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "PullToRefreshTableView.h"
#import "AlerViewManager.h"

#import "UITableView+ZGParallelView.h"
#import "AFOAuth2Client.h"
#import "IADisquser.h"
#import "IADisqusUser.h"

typedef void (^ActivityRevealBlock)();

@interface ActivityViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *following;//关注列表
    NSMutableArray *follower;//粉丝列表
    NSMutableArray *active;//动态列表
    NSMutableArray *post;//讨论列表
    
    //NSMutableArray *itunesAppnames;//从苹果商店获取的游戏名数据库
    //UIActivityIndicatorView *indicator;
    
    AlerViewManager *alerViewManager;
    NSInteger start;
    NSInteger receiveMember;
    BOOL ifNeedFristLoading;
    BOOL ifLoging;//是否已登录
    IADisqusUser *dUser;//个人页面的用户
    TableHeaderView *headerView;
    
    PullToRefreshTableView *pullToRefreshTableView;
    UIImageView *avatarImage;
    
@private
	ActivityRevealBlock _revealBlock;
}

//@property (nonatomic, copy) NSString *webURL;
@property (nonatomic, strong) IADisqusUser *dUser;
@property (nonatomic, strong) TableHeaderView *headerView;

@property (nonatomic, strong) PullToRefreshTableView *pullToRefreshTableView;
@property (strong, nonatomic) NSMutableArray *following;
@property (strong, nonatomic) NSMutableArray *follower;
@property (strong, nonatomic) NSMutableArray *active;
@property (strong, nonatomic) NSMutableArray *post;
//@property (strong, nonatomic) NSMutableArray *itunesAppnames;
//@property (nonatomic, copy)NSString *searchStr;
@property (nonatomic, retain) IADisquser *iaDisquser;
@property (nonatomic, strong) UIImageView *avatarImage;

- (id)initWithTitle:(NSString *)title withUser:(NSNumber *)userID withRevealBlock:(ActivityRevealBlock)revealBlock;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;

@end

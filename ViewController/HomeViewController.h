//
//  HomeViewController.h
//  RaidersDOTA
//
//  Created by 计 炜 on 13-6-8.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "PullToRefreshTableView.h"
#import "AlerViewManager.h"

typedef void (^HomeRevealBlock)();
@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>{

    NSMutableArray *comments;//数据源
    PullToRefreshTableView *pullToRefreshTableView;
    
    AlerViewManager *alerViewManager;
    NSString *webURL;
    NSInteger start;
    NSInteger receiveMember;
    BOOL ifNeedFristLoading;
@private
	HomeRevealBlock _revealBlock;
}

@property (nonatomic, copy) NSString *webURL;
@property (nonatomic, strong) PullToRefreshTableView * pullToRefreshTableView;
@property (strong, nonatomic) NSMutableArray *comments;

//- (id)initWithTitle:(NSString *)title withRevealBlock:(HomeRevealBlock)revealBlock;
- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;
@end
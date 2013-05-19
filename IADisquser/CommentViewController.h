//
//  CommentViewController.h
//  AppGame
//
//  Created by 计 炜 on 13-4-15.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "PullToRefreshTableView.h"
#import "AlerViewManager.h"

@interface CommentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate> {
    NSMutableArray *comments;//数据源
    //UIActivityIndicatorView *indicator;
    PullToRefreshTableView *pullToRefreshTableView;
    
    AlerViewManager *alerViewManager;
    NSString *webURL;
    NSNumber *thread;
    NSInteger start;
    NSInteger receiveMember;
    BOOL ifNeedFristLoading;
    BOOL hasNext;
    NSString *nextCursor;
}

@property (nonatomic, copy) NSString *webURL, *nextCursor;
@property (nonatomic, copy) NSNumber *thread;
@property (nonatomic, strong) PullToRefreshTableView * pullToRefreshTableView;
@property (strong, nonatomic) NSMutableArray *comments;

- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url threadID:(NSNumber *)threadID;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;
@end

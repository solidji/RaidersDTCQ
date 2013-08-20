//
//  HorizonViewController.h
//  RaidersDOTA
//
//  Created by 计 炜 on 13-7-9.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "POHorizontalList.h"
#import "AlerViewManager.h"
#import "PullToRefreshTableView.h"

@interface HorizonViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, POHorizontalListDelegate> {
    NSMutableArray *itemArray;
    
    NSMutableArray *freeList;
    NSMutableArray *paidList;
    NSMutableArray *grossingList;
    PullToRefreshTableView *horizontalTableView;
    AlerViewManager *alerViewManager;
    NSInteger receiveMember;
    
    NSMutableArray *liliangList;//数据源
    NSMutableArray *minjieList;//数据源
    NSMutableArray *zhiliList;//数据源
}

@property (nonatomic, strong) PullToRefreshTableView *horizontalTableView;
@property (strong, nonatomic) NSMutableArray *freeList,*paidList,*grossingList,*liliangList,*minjieList,*zhiliList;

- (id)initWithTitle:(NSString *)title;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;
@end

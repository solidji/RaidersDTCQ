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
    
    NSMutableArray *dataList1;
    NSMutableArray *dataList2;
    NSMutableArray *dataList3;
    NSMutableArray *dataList4;//数据源
    
    PullToRefreshTableView *horizontalTableView;
    AlerViewManager *alerViewManager;
    NSInteger receiveMember;
}

@property (nonatomic, strong) PullToRefreshTableView *horizontalTableView;
@property (strong, nonatomic) NSMutableArray *dataList1,*dataList2,*dataList3,*dataList4;

- (id)initWithTitle:(NSString *)title;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;
@end

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
#import "AKSegmentedControl.h"

typedef void (^HomeRevealBlock)();
@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>{

    NSMutableArray *dataList1;//数据源
    NSMutableArray *dataList2;//数据源
    NSMutableArray *dataList3;//数据源
    NSMutableArray *segStr;//标题,3个
    NSMutableArray *categoryStr;//分类,3个,对应标题
    
    AlerViewManager *alerViewManager;
    NSString *webURL;
    NSInteger start,start1,start2,start3;
    NSInteger receiveMember,receiveMember2,receiveMember3;
    BOOL ifNeedFristLoading;
    BOOL updating;//正在更新中,不要重复了
    CGRect myframe;
    
    PullToRefreshTableView *segOneTableView,*segTwoTableView,*segThreeTableView;
    AKSegmentedControl *segmentedPerson;
    UIButton *segOneBtn,*segTwoBtn,*segThreeBtn;
    
@private
	HomeRevealBlock _revealBlock;
}

@property (nonatomic, copy) NSString *webURL;
@property (nonatomic) CGRect myframe;
@property (strong, nonatomic) NSMutableArray *dataList1,*dataList2,*dataList3;
@property (strong, nonatomic) NSMutableArray *titleStr,*categoryStr;

@property (nonatomic, strong) PullToRefreshTableView *segOneTableView,*segTwoTableView,*segThreeTableView;
@property (nonatomic, strong) AKSegmentedControl *segmentedPerson;
@property (nonatomic, strong) UIButton *segOneBtn,*segTwoBtn,*segThreeBtn;


//- (id)initWithTitle:(NSString *)title withRevealBlock:(HomeRevealBlock)revealBlock;
- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url withFrame:(CGRect)frame;
- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url;
- (id)initWithTitle:(NSString *)title withSeg:(NSArray *)seg withCate:(NSArray *)cate withFrame:(CGRect)frame;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;

- (void)updateThread2:(NSString *)returnKey;
- (void)updateTableView2;

- (void)updateThread3:(NSString *)returnKey;
- (void)updateTableView3;
@end
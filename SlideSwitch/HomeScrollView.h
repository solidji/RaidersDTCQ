//
//  HomeScrollView.h
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

typedef void (^ScrollRevealBlock)();

@interface HomeScrollView : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    //这些是第一页需要的
    NSArray *viewNameArray;
    CGFloat userContentOffsetX;
    BOOL isLeftScroll;
    
    NSArray *nameArray;
    NSInteger userSelectedChannelID;        //点击按钮选择名字ID
    NSInteger scrollViewSelectedChannelID;  //滑动列表选择名字ID
    
    UIImageView *shadowImageView;
    
    UIScrollView *RootScrollView;
    UIScrollView *TopScrollView;
    
    //NSString *webURL;
    UIImageView *bgImage;
    
    //这些是第二页需要的
    NSMutableArray *comments;//数据源
    PullToRefreshTableView *pullToRefreshTableView;
    
    AlerViewManager *alerViewManager;
    NSString *webURL;
    NSInteger start;
    NSInteger receiveMember;
    BOOL ifNeedFristLoading;
    BOOL hasNext;
    NSString *nextCursor;
    
@private
	ScrollRevealBlock _revealBlock;
}
@property (nonatomic, retain) NSArray *viewNameArray;

@property (nonatomic, retain) NSArray *nameArray;
@property (nonatomic, assign) NSInteger scrollViewSelectedChannelID;

@property (nonatomic, retain) UIScrollView *RootScrollView, *TopScrollView;

//@property (nonatomic, copy) NSString *webURL;
@property (nonatomic, strong) UIImageView *bgImage;

@property (nonatomic, copy) NSString *webURL, *nextCursor;
@property (nonatomic, strong) PullToRefreshTableView * pullToRefreshTableView;
@property (strong, nonatomic) NSMutableArray *comments;

@property (nonatomic, retain) UIImageView *imgProfile;

//滑动撤销选中按钮
- (void)setButtonUnSelect;
//滑动选择按钮
- (void)setButtonSelect;

- (id)initWithTitle:(NSString *)title withRevealBlock:(ScrollRevealBlock)revealBlock;

//- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;

@end

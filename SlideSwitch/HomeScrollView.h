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
#import "AKSegmentedControl.h"
#import "HomeViewController.h"
#import "HorizonViewController.h"
#import "ASMediaThumbnailsViewController.h"
#import "CustomMosaicController.h"

@interface HomeScrollView : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{
    //这些是第一页需要的
    NSArray *viewNameArray;
    CGFloat userContentOffsetX;
    BOOL isLeftScroll;
    
    NSArray *nameArray,*buttonImage,*buttonBg;
    NSInteger userSelectedChannelID;        //点击按钮选择名字ID
    NSInteger scrollViewSelectedChannelID;  //滑动列表选择名字ID
    
    UIImageView *shadowImageView;
    
    UIScrollView *RootScrollView;
    UIScrollView *TopScrollView;
    
    //NSString *webURL;
    UIImageView *bgImage;
    
    AKSegmentedControl *segmentedNews,*segmentedNewer,*segmentedHero,*segmentedFb,*segmentedEquip;    
    HomeViewController *newsHotViewController,*newsHDViewController,*newsGGViewController;
    HomeViewController *newerJSViewController,*newerGLViewController;
    HomeViewController *heroGLViewController,*heroCZViewController;
    HomeViewController *fbGLViewController,*fbDLViewController;
    HomeViewController *zbHCViewController,*zbDLViewController,*zbTJViewController;
    
    HorizonViewController *heroHorizonViewController;
    ASMediaThumbnailsViewController *thumbnailsViewController;
    CustomMosaicController *customMosaicController;
    
    NSString *searchStr;
    UISearchBar *_searchBar;
    PullToRefreshTableView *searchView;
    NSMutableArray *articles;//搜索结果,文章数据源
    AlerViewManager *alerViewManager;
    NSInteger start;
    NSInteger receiveMember;
}
@property (nonatomic, retain) NSArray *viewNameArray;

@property (nonatomic, retain) NSArray *nameArray,*buttonImage,*buttonBg;
@property (nonatomic, assign) NSInteger scrollViewSelectedChannelID;

@property (nonatomic, retain) UIScrollView *RootScrollView, *TopScrollView;

//@property (nonatomic, copy) NSString *webURL;
@property (nonatomic, strong) UIImageView *bgImage;

@property (nonatomic, strong) AKSegmentedControl *segmentedNews,*segmentedNewer,*segmentedHero,*segmentedFb,*segmentedEquip;
@property (nonatomic, strong) HomeViewController *newsHotViewController,*newsHDViewController,*newsGGViewController;
@property (nonatomic, strong) HomeViewController *newerJSViewController,*newerGLViewController;
@property (nonatomic, strong) HomeViewController *heroGLViewController,*heroCZViewController;
@property (nonatomic, strong) HomeViewController *fbGLViewController,*fbDLViewController;
@property (nonatomic, strong) HomeViewController *zbHCViewController,*zbDLViewController,*zbTJViewController;
@property (nonatomic, strong) HorizonViewController *heroHorizonViewController;
@property (nonatomic, strong) ASMediaThumbnailsViewController *thumbnailsViewController;
@property (nonatomic, strong) CustomMosaicController *customMosaicController;

@property (nonatomic, copy) NSString *searchStr;
@property (nonatomic, strong) PullToRefreshTableView *searchView;
@property (strong, nonatomic) NSMutableArray *articles;

//滑动撤销选中按钮
- (void)setButtonUnSelect;
//滑动选择按钮
- (void)setButtonSelect;

- (id)initWithTitle:(NSString *)title;

- (void)updateThread:(NSString *)returnKey;
- (void)updateTableView;

@end

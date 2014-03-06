//
//  HomeTabViewController.h
//  RaidersSD
//
//  Created by 计 炜 on 13-8-28.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMFilterView.h"
#import "HomeViewController.h"
#import "HorizonViewController.h"
#import "GHRootViewController.h"
#import "SVWebViewController.h"
#import "doubleWebViewController.h"
#import "VideoViewController.h"
#import "HMSideMenu.h"
#import "JMTabView.h"

@interface HomeTabViewController : UIViewController <DMFilterViewDelegate,JMTabViewDelegate>
{
    HomeViewController *hotViewController;
    HomeViewController *videoViewController;
    HorizonViewController *dataViewController;
    HomeViewController *newsViewController;
    SVWebViewController *bbsViewController,*officialWebView;
    HMSideMenu *bbsSideMenu,*officialSideMenu;
}

@property (nonatomic, strong) DMFilterView *filterView;
@property (nonatomic, strong) HomeViewController *hotViewController,*newsViewController;
@property (nonatomic, strong) HomeViewController *videoViewController;
@property (nonatomic, strong) HorizonViewController *dataViewController;
@property (nonatomic, strong) SVWebViewController *bbsViewController,*officialWebView;
@property (nonatomic, strong) HMSideMenu *bbsSideMenu,*officialSideMenu;

- (id)initWithTitle:(NSString *)title;
@end

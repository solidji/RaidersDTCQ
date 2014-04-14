//
//  HomeTabViewController.h
//  RaidersSD
//
//  Created by 计 炜 on 13-8-28.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>
#import "DMFilterView.h"
#import "HomeViewController.h"
//#import "HorizonViewController.h"
#import "GHRootViewController.h"
#import "SVWebViewController.h"
#import "segWebViewController.h"
#import "DataViewController.h"
#import "HMSideMenu.h"
#import "JMTabView.h"

@interface HomeTabViewController : UIViewController <DMFilterViewDelegate,JMTabViewDelegate>
{
    HomeViewController *newsViewController;
    HomeViewController *videoViewController;
    DataViewController *dataViewController;
    HomeViewController *hotViewController;
    GHRootViewController *bbsViewController,*officialWebView;
    HMSideMenu *bbsSideMenu,*officialSideMenu;
}

@property (nonatomic, strong) DMFilterView *filterView;
@property (nonatomic, strong) HomeViewController *newsViewController;
@property (nonatomic, strong) HomeViewController *videoViewController,*hotViewController;
@property (nonatomic, strong) DataViewController *dataViewController;
@property (nonatomic, strong) GHRootViewController *bbsViewController,*officialWebView;
@property (nonatomic, strong) HMSideMenu *bbsSideMenu,*officialSideMenu;

- (id)initWithTitle:(NSString *)title;
@end

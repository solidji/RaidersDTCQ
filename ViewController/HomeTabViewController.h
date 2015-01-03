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

@interface HomeTabViewController : UIViewController <JMTabViewDelegate>
{
    GHRootViewController *newsViewController;
    GHRootViewController *videoViewController;
    GHRootViewController *hotViewController;
    GHRootViewController *bbsViewController,*officialWebView;
    
    DataViewController *dataViewController;
    HMSideMenu *bbsSideMenu,*officialSideMenu,*newsSideMenu,*tourSideMenu;
}

@property (nonatomic, strong) GHRootViewController *newsViewController;
@property (nonatomic, strong) GHRootViewController *videoViewController,*hotViewController;
@property (nonatomic, strong) DataViewController *dataViewController;
@property (nonatomic, strong) GHRootViewController *bbsViewController,*officialWebView;
@property (nonatomic, strong) HMSideMenu *bbsSideMenu,*officialSideMenu,*newsSideMenu,*tourSideMenu;

- (id)initWithTitle:(NSString *)title;
@end

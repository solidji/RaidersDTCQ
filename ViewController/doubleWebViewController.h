//
//  doubleWebViewController.h
//  RaidersSD
//
//  Created by 计 炜 on 13-8-31.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "AlerViewManager.h"
#import "AKSegmentedControl.h"
#import "SVWebViewController.h"
#import "HMSideMenu.h"

@interface doubleWebViewController : UIViewController
{
    SVWebViewController *bbsViewController,*officialWebView;
    AKSegmentedControl *segmentedPerson;
    UIButton *segOneBtn,*segTwoBtn;
    HMSideMenu *bbsSideMenu,*officialSideMenu;
}

@property (nonatomic, strong) SVWebViewController *bbsViewController,*officialWebView;
@property (nonatomic, strong) AKSegmentedControl *segmentedPerson;
@property (nonatomic, strong) UIButton *segOneBtn,*segTwoBtn;
@property (nonatomic, strong) HMSideMenu *bbsSideMenu,*officialSideMenu;

- (id)initWithURL:(NSURL*)URL another:(NSURL*)otherURL;

@end

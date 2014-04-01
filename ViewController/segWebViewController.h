//
//  segWebViewController.h
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
#import "GHRootViewController.h"
#import "HMSideMenu.h"

@interface segWebViewController : UIViewController
{
    GHRootViewController *webVC1,*webVC2,*webVC3;
    AKSegmentedControl *segmentedPerson;
    UIButton *segOneBtn,*segTwoBtn,*segThreeBtn;
    HMSideMenu *webSideMenu1,*webSideMenu2,*webSideMenu3;
    
    NSMutableArray *segStr;//标题,3个
    NSMutableArray *categoryStr;//分类,3个,对应标题
    
    CGRect myframe;
}

@property (nonatomic, strong) GHRootViewController *webVC1,*webVC2,*webVC3;
@property (nonatomic, strong) AKSegmentedControl *segmentedPerson;
@property (nonatomic, strong) UIButton *segOneBtn,*segTwoBtn,*segThreeBtn;
@property (nonatomic, strong) HMSideMenu *webSideMenu1,*webSideMenu2,*webSideMenu3;
@property (strong, nonatomic) NSMutableArray *segStr,*categoryStr;
@property (nonatomic) CGRect myframe;

- (id)initWithURL:(NSURL*)URL another:(NSURL*)anotherURL other:(NSURL*)otherURL;
- (id)initWithTitle:(NSString *)title withSeg:(NSArray *)seg withCate:(NSArray *)cate withFrame:(CGRect)frame;

@end

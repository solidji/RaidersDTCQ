//
//  CustomMosaicDatasource.h
//  RaidersDOTA
//
//  Created by 计 炜 on 13-7-12.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MosaicView.h"
#import "MosaicViewDelegateProtocol.h"
#import "MosaicViewDatasourceProtocol.h"
#import "AlerViewManager.h"

@interface CustomMosaicController : UIViewController <MosaicViewDelegateProtocol,MosaicViewDatasourceProtocol>{
    MosaicView *mosaicView;
    NSMutableArray *elements;
    NSMutableArray *comments;//数据源
    AlerViewManager *alerViewManager;
}

@property (strong, strong) MosaicView *mosaicView;
@property (strong, nonatomic) NSMutableArray *elements,*comments;

- (id)initWithTitle:(NSString *)title withFrame:(CGRect)frame;
- (void)getComments;
- (void)refresh;
@end
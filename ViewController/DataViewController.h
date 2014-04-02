//
//  DataViewController.h
//  RaidersDtcq
//
//  Created by 计 炜 on 14-3-9.
//  Copyright (c) 2014年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "dataCell.h"
#import "LineLayout.h"

@interface DataViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate> {
    NSMutableArray *dataList1;//数据源
    NSMutableArray *dataList2;//数据源
    NSMutableArray *dataList3;//数据源
    NSMutableArray *dataList4;
}

@property (strong, nonatomic) NSMutableArray *dataList1,*dataList2,*dataList3,*dataList4;

@end

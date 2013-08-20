//
//  PhotosDataSource.h
//  PhotosDataSource
//
//  Created by Andy soonest on 11-11-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ScrollPageDataSource <NSObject>

//有多少页
- (int)numberOfPages;

//每页的图片
- (UIImageView *)imageAtIndex:(int)index;

//需要下载
- (void)pageImageNeedDownlod:(NSInteger)index;

//被点击
- (void)pageDidSelceted:(NSInteger)index;

@end

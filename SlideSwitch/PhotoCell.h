//
//  PhotoCell.h
//  RaidersDOTA
//
//  Created by 计 炜 on 13-7-12.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UITableViewCell {
    UIImageView *imageView,*imageView2,*imageView3;
    UILabel *descriptLabel;
    UILabel *dateLabel;
    UILabel *articleLabel;
    UILabel *creatorLabel;
    
}

@property (nonatomic, strong) UIImageView *imageView,*imageView2,*imageView3;
@property (nonatomic, strong) UILabel *descriptLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *articleLabel;
@property (nonatomic, strong) UILabel *creatorLabel;

@end

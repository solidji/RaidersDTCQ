//
//  ActivityItemCell.h
//  AppGame
//
//  Created by 计 炜 on 13-5-20.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityItemCell : UITableViewCell {
    
    UIImageView *imageView;
    UIImageView *imageType;
    UIImageView *imageCreator;

    UILabel *dateLabel;
    UILabel *articleLabel;//文章标题
    UILabel *creatorLabel;
    
    UIButton *personalButton;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *imageType;
@property (nonatomic, strong) UIImageView *imageCreator;

@property (nonatomic, strong) UIButton *personalButton;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *articleLabel;
@property (nonatomic, strong) UILabel *creatorLabel;

@end

//
//  UserItemCell.h
//  AppGame
//
//  Created by 计 炜 on 13-5-29.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserItemCell : UITableViewCell{
    
    UIImageView *imageView;
    UIImageView *imageType;
    
    UILabel *dateLabel;
    UILabel *articleLabel;//文章标题
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *imageType;

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *articleLabel;

@end

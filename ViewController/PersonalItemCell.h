//
//  PersonalItemCell.h
//  AppGame
//
//  Created by 计 炜 on 13-5-30.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalItemCell : UITableViewCell {
    UIImageView *imageView;
    UILabel *nameLabel;
    UILabel *dateLabel;
    UILabel *articleLabel;
    UILabel *creatorLabel;
    
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *articleLabel;
@property (nonatomic, strong) UILabel *creatorLabel;

@end

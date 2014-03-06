//
//  HomeViewCell.h
//  AppGame
//
//  Created by 计 炜 on 13-8-2.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewCell : UITableViewCell {
    UIImageView *imageView;
    UILabel *descriptLabel;
    UILabel *dateLabel;
    UILabel *articleLabel;
    UILabel *creatorLabel;
    
    UIView *topLine;
    UIView *bottomLine;
    
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *descriptLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *articleLabel;
@property (nonatomic, strong) UILabel *creatorLabel;

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *bottomLine;

@end

//
//  PersonalItemCell.m
//  AppGame
//
//  Created by 计 炜 on 13-5-30.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "PersonalItemCell.h"

@implementation PersonalItemCell

@synthesize imageView, nameLabel, dateLabel, articleLabel, creatorLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        nameLabel = [[UILabel alloc] init];
        [nameLabel setTextColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]];
        [nameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];//每行高度20
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setLineBreakMode:NSLineBreakByClipping];
        [nameLabel setNumberOfLines:0];
        [self.contentView addSubview:nameLabel];
        
        articleLabel = [[UILabel alloc] init];
        [articleLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
        [articleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];//每行高度15
        //[articleLabel setMinimumScaleFactor:12.0];//setMinimumFontSize
        if ([articleLabel respondsToSelector: @selector(setMinimumScaleFactor:)]) {
            [articleLabel setMinimumScaleFactor:12.0];
        }
        else {
            [articleLabel setMinimumFontSize:12.0];
        }
        [articleLabel setBackgroundColor:[UIColor clearColor]];
        [articleLabel setLineBreakMode:NSLineBreakByTruncatingTail];//UILineBreakModeWordWrap
        [articleLabel setNumberOfLines:0];
        [self.contentView addSubview:articleLabel];
        
        dateLabel = [[UILabel alloc] init];
        [dateLabel setTextColor:[UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0]];
        [dateLabel setFont:[UIFont fontWithName:@"Helvetica" size:11.0]];//每行高度14
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:dateLabel];
        
        creatorLabel = [[UILabel alloc] init];
        [creatorLabel setTextColor:[UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0]];
        [creatorLabel setFont:[UIFont fontWithName:@"Helvetica" size:11.0]];//每行高度14
        [creatorLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:creatorLabel];
        
        imageView = [[UIImageView alloc] init];
        [imageView setContentMode:UIViewContentModeScaleToFill];
        [imageView setBackgroundColor:[UIColor clearColor]];//lightGrayColor
        [imageView.layer setMasksToBounds:YES];
        [imageView.layer setOpaque:NO];
        [imageView.layer setCornerRadius:5.0];
        [self.contentView addSubview:imageView];
        
        //增加上下分割线
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		topLine.backgroundColor = [UIColor colorWithRed:(235.0f/255.0f) green:(231.0f/255.0f) blue:(226.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:topLine];
		
        UIView *topLine2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		topLine2.backgroundColor = [UIColor colorWithRed:(249.0f/255.0f) green:(245.0f/255.0f) blue:(240.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:topLine2];
        
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 51.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(246.0f/255.0f) green:(242.0f/255.0f) blue:(237.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:bottomLine];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    //    CGSize constraint = CGSizeMake(200, 20000);
    //    CGSize size = [@"多" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    [nameLabel setFrame:CGRectMake(52.0, 0, 320-52.0, 26)];
    [articleLabel setFrame:CGRectMake(52.0, 26.0, 320-52.0, 26)];
    //[dateLabel setFrame:CGRectMake(8.0, 148-8-14, 100.0, 14.0)];
    //[creatorLabel setFrame:CGRectMake(108.0, 148-8-14, 100.0, 14.0)];
    [imageView setFrame:CGRectMake(10.0, 10.0, 32.0, 32.0)];
}

@end

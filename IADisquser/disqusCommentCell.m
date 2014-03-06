//
//  disqusCommentCell.m
//  AppGame
//
//  Created by 计 炜 on 13-4-14.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "disqusCommentCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation disqusCommentCell

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
        //nameLabel.textAlignment = UITextAlignmentLeft;//置左
        //[self.contentView addSubview:nameLabel];
        
        articleLabel = [[UILabel alloc] init];
        [articleLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
        [articleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0]];//每行高度15
        //[articleLabel setMinimumScaleFactor:12.0];//setMinimumFontSize
        if ([articleLabel respondsToSelector: @selector(setMinimumScaleFactor:)]) {
            [articleLabel setMinimumScaleFactor:13.0];
        }
        else {
            [articleLabel setMinimumFontSize:13.0];
        }
        [articleLabel setBackgroundColor:[UIColor clearColor]];
        [articleLabel setLineBreakMode:NSLineBreakByWordWrapping];//UILineBreakModeWordWrap
        [articleLabel setNumberOfLines:0];
        [self.contentView addSubview:articleLabel];
        
        dateLabel = [[UILabel alloc] init];
        [dateLabel setTextColor:[UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0]];
        [dateLabel setFont:[UIFont fontWithName:@"Helvetica" size:11.0]];//每行高度14
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        //[self.contentView addSubview:dateLabel];
        
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
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		topLine.backgroundColor = [UIColor colorWithRed:(235.0f/255.0f) green:(231.0f/255.0f) blue:(226.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:topLine];
		
        UIView *topLine2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 2.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		topLine2.backgroundColor = [UIColor colorWithRed:(249.0f/255.0f) green:(245.0f/255.0f) blue:(240.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:topLine2];
        
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
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
        
    //[nameLabel setFrame:CGRectMake(8.0+46.0+8.0, 16.0, 320.0-16.0-46.0, 20.0)];
    [imageView setFrame:CGRectMake(8.0, 8.0, 36.0, 36.0)];
    [creatorLabel setFrame:CGRectMake(8.0+36.0+8.0, 8.0, 100.0, 18.0)];
    //[dateLabel setFrame:CGRectMake(8.0+36.0+8.0+8.0+100, 8.0, 100.0, 18.0)];
}

@end

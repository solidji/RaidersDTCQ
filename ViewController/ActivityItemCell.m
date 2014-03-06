//
//  ActivityItemCell.m
//  AppGame
//
//  Created by 计 炜 on 13-5-20.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ActivityItemCell.h"

@implementation ActivityItemCell

@synthesize imageView, imageType, imageCreator, dateLabel, articleLabel, creatorLabel, personalButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        articleLabel = [[UILabel alloc] init];
        [articleLabel setTextColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]];
        [articleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];//每行高度20
        [articleLabel setBackgroundColor:[UIColor clearColor]];
        [articleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [articleLabel setNumberOfLines:1];
        [self.contentView addSubview:articleLabel];
                
        dateLabel = [[UILabel alloc] init];
        [dateLabel setTextColor:[UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0]];
        [dateLabel setFont:[UIFont fontWithName:@"Helvetica" size:11.0]];//每行高度14
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [dateLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [dateLabel setNumberOfLines:1];
        [self.contentView addSubview:dateLabel];
        
        creatorLabel = [[UILabel alloc] init];
        [creatorLabel setTextColor:[UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0]];
        [creatorLabel setFont:[UIFont fontWithName:@"Helvetica" size:11.0]];//每行高度14
        [creatorLabel setBackgroundColor:[UIColor clearColor]];
        [creatorLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [creatorLabel setNumberOfLines:1];
        [self.contentView addSubview:creatorLabel];
        
        imageView = [[UIImageView alloc] init];
        [imageView setContentMode:UIViewContentModeScaleToFill];
        [imageView setBackgroundColor:[UIColor clearColor]];//lightGrayColor
        [imageView.layer setMasksToBounds:YES];
        [imageView.layer setOpaque:NO];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [imageView.layer setBorderWidth: 2.0];
        [imageView.layer setCornerRadius:25.0];
        [self.contentView addSubview:imageView];
        
        imageCreator = [[UIImageView alloc] init];
        [imageCreator setContentMode:UIViewContentModeScaleToFill];
        [imageCreator setBackgroundColor:[UIColor clearColor]];//lightGrayColor
        [imageCreator.layer setMasksToBounds:YES];
        [imageCreator.layer setOpaque:NO];
        [imageCreator setBackgroundColor:[UIColor clearColor]];
        [imageCreator.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [imageCreator.layer setBorderWidth: 1.0];
        [imageCreator.layer setCornerRadius:16.0];
        [self.contentView addSubview:imageCreator];
        
        //增加上下分割线
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		topLine.backgroundColor = [UIColor colorWithRed:(235.0f/255.0f) green:(231.0f/255.0f) blue:(226.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:topLine];
		
        UIView *topLine2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		topLine2.backgroundColor = [UIColor colorWithRed:(249.0f/255.0f) green:(245.0f/255.0f) blue:(240.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:topLine2];
        
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 79.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(246.0f/255.0f) green:(242.0f/255.0f) blue:(237.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:bottomLine];
        
        //增加竖直分割线
        UIView *verticalLine1 = [[UIView alloc] initWithFrame:CGRectMake(79.0f, 0.0f, 1.0f, 32.0f)];
		verticalLine1.backgroundColor = [UIColor colorWithRed:(232.0f/255.0f) green:(228.0f/255.0f) blue:(224.0f/255.0f) alpha:1.0f];
		[self.contentView addSubview:verticalLine1];
        UIView *verticalLine2 = [[UIView alloc] initWithFrame:CGRectMake(80.0f, 0.0f, 1.0f, 32.0f)];
		verticalLine2.backgroundColor = [UIColor colorWithRed:(221.0f/255.0f) green:(217.0f/255.0f) blue:(213.0f/255.0f) alpha:1.0f];
		[self.contentView addSubview:verticalLine2];
        UIView *verticalLine3 = [[UIView alloc] initWithFrame:CGRectMake(81.0f, 0.0f, 1.0f, 32.0f)];
		verticalLine3.backgroundColor = [UIColor colorWithRed:(228.0f/255.0f) green:(224.0f/255.0f) blue:(220.0f/255.0f) alpha:1.0f];
		[self.contentView addSubview:verticalLine3];
        
        UIView *verticalLine11 = [[UIView alloc] initWithFrame:CGRectMake(79.0f, 47.0f, 1.0f, 33.0f)];
		verticalLine11.backgroundColor = [UIColor colorWithRed:(232.0f/255.0f) green:(228.0f/255.0f) blue:(224.0f/255.0f) alpha:1.0f];
		[self.contentView addSubview:verticalLine11];
        UIView *verticalLine22 = [[UIView alloc] initWithFrame:CGRectMake(80.0f, 47.0f, 1.0f, 33.0f)];
		verticalLine22.backgroundColor = [UIColor colorWithRed:(221.0f/255.0f) green:(217.0f/255.0f) blue:(213.0f/255.0f) alpha:1.0f];
		[self.contentView addSubview:verticalLine22];
        UIView *verticalLine33 = [[UIView alloc] initWithFrame:CGRectMake(81.0f, 47.0f, 1.0f,33.0f)];
		verticalLine33.backgroundColor = [UIColor colorWithRed:(228.0f/255.0f) green:(224.0f/255.0f) blue:(220.0f/255.0f) alpha:1.0f];
		[self.contentView addSubview:verticalLine33];
        
        imageType = [[UIImageView alloc] init];
        [imageType setContentMode:UIViewContentModeScaleToFill];
        [imageType setBackgroundColor:[UIColor clearColor]];//lightGrayColor
        [self.contentView addSubview:imageType];
        
        //[self.contentView bringSubviewToFront:imageType];
        
        personalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        personalButton.backgroundColor = [UIColor clearColor];
        personalButton.userInteractionEnabled = YES;
        [self addSubview:personalButton];
        //[self.contentView bringSubviewToFront:personalButton];
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
    
    [articleLabel setFrame:CGRectMake(105.0, 0.0, 320.0-105.0, 40.0)];
    [creatorLabel setFrame:CGRectMake(145.0, 40.0, 320.0-145.0, 14.0)];
    [dateLabel setFrame:CGRectMake(145.0, 56.0, 320.0-145.0, 14.0)];
    
    [imageView setFrame:CGRectMake(15.0, 15.0, 50.0, 50.0)];
    [imageType setFrame:CGRectMake(72.5, 32.0, 15.0, 15.0)];
    [imageCreator setFrame:CGRectMake(105.0, 40.0, 32.0, 32.0)];
    [personalButton setFrame:CGRectMake(105.0, 40.0, 320.0-105.0, 40.0)];
}

@end

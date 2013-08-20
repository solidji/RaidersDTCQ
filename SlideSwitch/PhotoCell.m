//
//  PhotoCell.m
//  RaidersDOTA
//
//  Created by 计 炜 on 13-7-12.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "PhotoCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PhotoCell

@synthesize imageView,imageView2,imageView3, descriptLabel, dateLabel, articleLabel, creatorLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        articleLabel = [[UILabel alloc] init];
        [articleLabel setTextColor:[UIColor blackColor]];
        //[articleLabel setTextColor:[UIColor colorWithRed:135.0/255.0 green:200.0/255.0 blue:235.0/255.0 alpha:1.0]];
        [articleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
        //[articleLabel setMinimumScaleFactor:12.0];//setMinimumFontSize
        if ([articleLabel respondsToSelector: @selector(setMinimumScaleFactor:)]) {
            [articleLabel setMinimumScaleFactor:15.0];
        }
        else {
            [articleLabel setMinimumFontSize:15.0];
        }
        [articleLabel setBackgroundColor:[UIColor clearColor]];
        [articleLabel setLineBreakMode:NSLineBreakByWordWrapping];//UILineBreakModeWordWrap
        [articleLabel setNumberOfLines:0];
        [self.contentView addSubview:articleLabel];//副本标题
        
        imageView = [[UIImageView alloc] init];//第一张图,一般是BOSS组合
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setBackgroundColor:[UIColor clearColor]];//lightGrayColor
        //[imageView.layer setOpaque:NO];
        //[imageView.layer setCornerRadius:5.0];
        CALayer *roundCorner = [imageView layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setBorderColor:[UIColor blackColor].CGColor];
        [roundCorner setBorderWidth:1.0];
        [self.contentView addSubview:imageView];
        
        imageView2 = [[UIImageView alloc] init];//第二张图
        [imageView2 setContentMode:UIViewContentModeScaleAspectFill];
        [imageView2 setBackgroundColor:[UIColor clearColor]];//lightGrayColor
        //[imageView.layer setOpaque:NO];
        //[imageView.layer setCornerRadius:5.0];
        [imageView2.layer setMasksToBounds:YES];
        [imageView2.layer setBorderColor:[UIColor blackColor].CGColor];
        [imageView2.layer setBorderWidth:1.0];
        [self.contentView addSubview:imageView2];
        
        imageView3 = [[UIImageView alloc] init];//第三张图
        [imageView3 setContentMode:UIViewContentModeScaleAspectFill];
        [imageView3 setBackgroundColor:[UIColor clearColor]];//lightGrayColor
        //[imageView.layer setOpaque:NO];
        //[imageView.layer setCornerRadius:5.0];
        [imageView3.layer setMasksToBounds:YES];
        [imageView3.layer setBorderColor:[UIColor blackColor].CGColor];
        [imageView3.layer setBorderWidth:1.0];
        [self.contentView addSubview:imageView3];
        
        //增加上下分割线
        //		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
        //		topLine.backgroundColor = [UIColor colorWithRed:(9.0f/255.0f) green:(37.0f/255.0f) blue:(58.0f/255.0f) alpha:1.0f];
        //		[self.textLabel.superview addSubview:topLine];
        //
        //        UIView *topLine2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
        //		topLine2.backgroundColor = [UIColor colorWithRed:(37.0f/255.0f) green:(65.0f/255.0f) blue:(86.0f/255.0f) alpha:1.0f];
        //		[self.textLabel.superview addSubview:topLine2];
        
		//UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		//bottomLine.backgroundColor = [UIColor whiteColor];
		//[self.textLabel.superview addSubview:bottomLine];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGFloat dashArray[] = {4,2};
    CGContextSetLineDash(context, 0, dashArray, 2);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 320.0, 0.0);
    CGContextStrokePath(context);
    //CGContextClosePath(context);
}

@end
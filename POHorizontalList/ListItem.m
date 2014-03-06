//
//  ListItem.m
//  POHorizontalList
//
//  Created by Polat Olu on 15/02/2013.
//  Copyright (c) 2013 Polat Olu. All rights reserved.
//

#import "ListItem.h"

@implementation ListItem

- (id)initWithFrame:(CGRect)frame image:(UIImageView *)image text:(NSString *)imageTitle
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        self.imageTitle = imageTitle;
        self.image = image;
        
        //UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        UIImageView *imageView = self.image;
        
        CALayer *roundCorner = [imageView layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:8.0];
        [roundCorner setBorderColor:[UIColor grayColor].CGColor];
        [roundCorner setBorderWidth:1.0];
        
        UILabel *title = [[UILabel alloc] init];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setFont:[UIFont boldSystemFontOfSize:11.0]];
        [title setOpaque: NO];
        [title setText:imageTitle];
        title.textAlignment = UITextAlignmentCenter;
        
        imageRect = CGRectMake(9.2, 0.0, 64, 64);
        textRect = CGRectMake(-7.0, imageRect.origin.y + imageRect.size.height + 8.0, 80.0, 20.0);
        
        [title setFrame:textRect];
        [imageView setFrame:imageRect];
        
        [self addSubview:title];
        [self addSubview:imageView];
    }
    
    return self;
}

@end

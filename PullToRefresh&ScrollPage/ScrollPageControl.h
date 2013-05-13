//
//  ScrollPageControl.h
//  PhotosPageControl
//
//  Created by Miaohz on 11-8-31.
//  Copyright 2011 Etop. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScrollPageControl : UIPageControl {
	UIImage *imagePageStateNormal;
	UIImage *imagePageStateHightlighted;
}

- (id) initWithFrame:(CGRect)frame;

@property (nonatomic, retain) UIImage *imagePageStateNormal;
@property (nonatomic, retain) UIImage *imagePageStateHightlighted;

@end

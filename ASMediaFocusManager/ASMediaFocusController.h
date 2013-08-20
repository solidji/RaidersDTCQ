//
//  ASMediaFocusViewController.h
//  ASMediaFocusManager
//
//  Created by Philippe Converset on 21/12/12.
//  Copyright (c) 2012 AutreSphere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASImageScrollView.h"

@interface ASMediaFocusController : UIViewController {
    UIImageView *mainImageView;
    UIView *contentView;
    UILabel *titleLabel;
}

@property (strong, nonatomic) ASImageScrollView *scrollView;
@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *accessoryView;

- (void)updateOrientationAnimated:(BOOL)animated;
- (void)installZoomView;
- (void)uninstallZoomView;
- (void)pinAccessoryViews;

@end

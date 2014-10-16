//
//  UIViewController+AGExtension.m
//  LittleGame
//
//  Created by Mao on 14-8-25.
//  Copyright (c) 2014年 Mao. All rights reserved.
//

#import "UIViewController+AGExtension.h"
@implementation UIViewController (AGExtension)
- (UIViewController *)ag_fatherViewController
{
    UIViewController *viewController = (UIViewController *)self.nextResponder;
    while (![viewController isKindOfClass:[UIViewController class]]) {
        viewController = (UIViewController *)viewController.nextResponder;
    }
    return viewController;
}

- (void)setDefaultLeftBarButtonItem
{
    if (self.navigationController.viewControllers.count > 1) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *imgBtn = [UIImage imageNamed:@"Return.png"];
        CGRect rect;
        rect = leftButton.frame;
        rect.size  = imgBtn.size;
        leftButton.frame = rect;
        
        [leftButton setBackgroundImage:imgBtn forState:UIControlStateNormal];
        [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setShowsTouchWhenHighlighted:YES];
        [leftButton addTarget:self action:@selector(clickGoBackButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *temporaryLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        temporaryLeftBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.leftBarButtonItem = temporaryLeftBarButtonItem;
    }
}
#pragma mark - gesture delegate
- (void)clickGoBackButton:(id)sender
{
    [self goBack];
}
- (void)goBack
{
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end

//
//  UIViewController+AGExtension.h
//  LittleGame
//
//  Created by Mao on 14-8-25.
//  Copyright (c) 2014年 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AGExtension)
- (UIViewController *)ag_fatherViewController;
- (void)setDefaultLeftBarButtonItem;
@end

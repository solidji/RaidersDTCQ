//
//  SettingViewController.h
//  AppGame
//
//  Created by ji wei on 13-4-8.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "QuickDialogController.h"
#import "AlerViewManager.h"

typedef void (^MySetRevealBlock)();

@interface SettingViewController : QuickDialogController {
    AlerViewManager *alerViewManager;
    NSString *webURL;
@private
	MySetRevealBlock _revealBlock;
}

@property (nonatomic, copy) NSString *webURL;
- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url withRevealBlock:(MySetRevealBlock)revealBlock;
@end

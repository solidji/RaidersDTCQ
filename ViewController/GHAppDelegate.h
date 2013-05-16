//
//  GHAppDelegate.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>


@interface GHAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate> {

    UIView *userMsgView;
    UIImageView *userMsgIcon;
    UIButton *userMsgButton;
    UIButton *cancelUserMsgButton;
    UILabel *userMsgLabel;
    NSMutableArray *userMsgArray;
    BOOL ifUserMsgCircleRunning;
}

- (void)showNewReger;
- (void)showWelcome;
- (void)showNewAward;
- (void)showFreeMsg:(NSString *)type withMsg:(NSString *)msg;

@end

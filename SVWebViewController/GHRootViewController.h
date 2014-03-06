//
//  GHRootViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

enum {
    GHWebViewControllerAvailableActionsNone             = 0,
    GHWebViewControllerAvailableActionsOpenInSafari     = 1 << 0,
    GHWebViewControllerAvailableActionsMailLink         = 1 << 1,
    GHWebViewControllerAvailableActionsCopyLink         = 1 << 2
};

typedef NSUInteger GHWebViewControllerAvailableActions;


typedef void (^RevealBlock)();
//UIViewController
@interface GHRootViewController : UIViewController <UIWebViewDelegate,UIGestureRecognizerDelegate>{
    
    NSURL *webURL;
    UIActivityIndicatorView *activityIndicator;
@private
	RevealBlock _revealBlock;
}

@property (nonatomic, strong) NSURL *webURL;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, readwrite) GHWebViewControllerAvailableActions availableActions;

- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url withRevealBlock:(RevealBlock)revealBlock;
- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url;
@end

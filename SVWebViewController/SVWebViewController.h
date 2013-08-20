//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import <MessageUI/MessageUI.h>

#import "SVModalWebViewController.h"
#import "ArticleItem.h"
#import "AlerViewManager.h"

@interface SVWebViewController : UIViewController<UIGestureRecognizerDelegate>{
    UIWebView *mainWebView;
}

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;
- (id)initWithHTMLString:(ArticleItem*)htmlString URL:(NSURL*)pageURL;

@property (nonatomic, readwrite) SVWebViewControllerAvailableActions availableActions;
@property (nonatomic, strong) UIWebView *mainWebView;
@end

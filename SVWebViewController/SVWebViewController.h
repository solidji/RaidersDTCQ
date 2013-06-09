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
#import "YIPopupTextView.h"
#import "VerticalSwipeScrollView.h"

@interface SVWebViewController : UIViewController<UIGestureRecognizerDelegate,YIPopupTextViewDelegate,VerticalSwipeScrollViewDelegate, UIScrollViewDelegate>{
    
    UIView* headerView;
    UIImageView* headerImageView;
    UILabel* headerLabel;
    
    UIView* footerView;
    UIImageView* footerImageView;
    UILabel* footerLabel;
    
    VerticalSwipeScrollView* verticalSwipeScrollView;
    NSArray* appData;
    NSUInteger startIndex;
    UIWebView* previousPage;
    UIWebView* nextPage;
}

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;
- (id)initWithHTMLString:(ArticleItem*)htmlString URL:(NSURL*)pageURL;

@property (nonatomic, readwrite) SVWebViewControllerAvailableActions availableActions;

@property (nonatomic, retain) UIView* headerView;
@property (nonatomic, retain) UIImageView* headerImageView;
@property (nonatomic, retain) UILabel* headerLabel;
@property (nonatomic, retain) UIView* footerView;
@property (nonatomic, retain) UIImageView* footerImageView;
@property (nonatomic, retain) UILabel* footerLabel;
@property (nonatomic, retain) VerticalSwipeScrollView* verticalSwipeScrollView;
@property (nonatomic, retain) NSArray* appData;
@property (nonatomic) NSUInteger startIndex;
@property (nonatomic, retain) UIWebView* previousPage;
@property (nonatomic, retain) UIWebView* nextPage;

@end

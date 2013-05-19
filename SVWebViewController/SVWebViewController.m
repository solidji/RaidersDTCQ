//
//  SVWebViewController.m
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVWebViewController.h"
#import "IADisquser.h"
#import "CommentViewController.h"

@interface SVWebViewController () <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong, readonly) UIBarButtonItem *popBarButtonItem;
@property (nonatomic, strong, readonly) UIButton *favoriteBarButton;
@property (nonatomic, strong, readonly) UIBarButtonItem *favoriteBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, strong, readonly) UIActionSheet *pageActionSheet;


@property (nonatomic, strong) UIWebView *mainWebView;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic) BOOL isHide;
@property (nonatomic, strong) ArticleItem *htmlString;
@property (strong, nonatomic) NSMutableArray *articles;//收藏文章数据源
@property (nonatomic, strong) AlerViewManager *alerViewManager;

- (id)initWithHTMLString:(ArticleItem*)htmlString URL:(NSURL*)pageURL;
- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;

- (void)updateToolbarItems;

- (void)goPopClicked:(UIBarButtonItem *)sender;
- (void)goFavoriteClicked:(UIButton *)sender;
- (void)goBackClicked:(UIBarButtonItem *)sender;
- (void)goForwardClicked:(UIBarButtonItem *)sender;
- (void)reloadClicked:(UIBarButtonItem *)sender;
- (void)stopClicked:(UIBarButtonItem *)sender;
- (void)actionButtonClicked:(UIBarButtonItem *)sender;

@end


@implementation SVWebViewController

@synthesize availableActions;

@synthesize URL, mainWebView, isHide;
@synthesize popBarButtonItem, favoriteBarButton, favoriteBarButtonItem, backBarButtonItem, forwardBarButtonItem, refreshBarButtonItem, stopBarButtonItem, actionBarButtonItem, pageActionSheet;

#pragma mark - setters and getters
- (UIBarButtonItem *)popBarButtonItem {
    
    if (!popBarButtonItem) {
        popBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"lift.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goPopClicked:)];
        popBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
		popBarButtonItem.width = 18.0f;
    }
    return popBarButtonItem;
}

- (UIBarButtonItem *)favoriteBarButtonItem {
    
    if (!favoriteBarButtonItem) {
        favoriteBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:favoriteBarButton];
        favoriteBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
		favoriteBarButtonItem.width = 18.0f;
    }
    return favoriteBarButtonItem;
}


- (UIBarButtonItem *)backBarButtonItem {
    
    if (!backBarButtonItem) {
        backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackClicked:)];
        backBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
		backBarButtonItem.width = 18.0f;
    }
    return backBarButtonItem;
}

- (UIBarButtonItem *)forwardBarButtonItem {
    
    if (!forwardBarButtonItem) {
        forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/forward"] style:UIBarButtonItemStylePlain target:self action:@selector(goForwardClicked:)];
        forwardBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
		forwardBarButtonItem.width = 18.0f;
    }
    return forwardBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    
    if (!refreshBarButtonItem) {
        refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadClicked:)];
    }
    
    return refreshBarButtonItem;
}

- (UIBarButtonItem *)stopBarButtonItem {
    
    if (!stopBarButtonItem) {
        stopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopClicked:)];
    }
    return stopBarButtonItem;
}

- (UIBarButtonItem *)actionBarButtonItem {
    
    if (!actionBarButtonItem) {
        actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];
    }
    return actionBarButtonItem;
}

- (UIActionSheet *)pageActionSheet {
    
    if(!pageActionSheet) {
        pageActionSheet = [[UIActionSheet alloc]
                           initWithTitle:self.mainWebView.request.URL.absoluteString
                           delegate:self
                           cancelButtonTitle:nil
                           destructiveButtonTitle:nil
                           otherButtonTitles:nil];
        
        if((self.availableActions & SVWebViewControllerAvailableActionsCopyLink) == SVWebViewControllerAvailableActionsCopyLink)
            [pageActionSheet addButtonWithTitle:NSLocalizedString(@"复制链接", @"")];
        
        if((self.availableActions & SVWebViewControllerAvailableActionsOpenInSafari) == SVWebViewControllerAvailableActionsOpenInSafari)
            [pageActionSheet addButtonWithTitle:NSLocalizedString(@"在Safari中打开", @"")];
        
        if([MFMailComposeViewController canSendMail] && (self.availableActions & SVWebViewControllerAvailableActionsMailLink) == SVWebViewControllerAvailableActionsMailLink)
            [pageActionSheet addButtonWithTitle:NSLocalizedString(@"用邮件发送", @"")];
        
        [pageActionSheet addButtonWithTitle:NSLocalizedString(@"取消", @"")];
        pageActionSheet.cancelButtonIndex = [self.pageActionSheet numberOfButtons]-1;
    }
    
    return pageActionSheet;
}

#pragma mark - Initialization

- (id)initWithHTMLString:(ArticleItem*)htmlString URL:(NSURL*)pageURL {
    self.htmlString = htmlString;
    return [self initWithURL:pageURL];
}
- (id)initWithAddress:(NSString *)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL*)pageURL {
    
    if(self = [super init]) {
        self.URL = pageURL;
        self.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsMailLink | SVWebViewControllerAvailableActionsCopyLink;
    }
    
//    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
//    [self.view addGestureRecognizer:singleTap];
//    singleTap.delegate = self;
//    singleTap.cancelsTouchesInView = NO;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePanGesture:)];
    //panGesture.delegate = self;
    panGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:panGesture];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleSwipeGesture:)];
    swipeGesture.delegate = self;
    [swipeGesture setDirection:(UISwipeGestureRecognizerDirectionRight)];
    swipeGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:swipeGesture];
    
    //[panGesture requireGestureRecognizerToFail:swipeGesture];
    
    return self;
}

#pragma mark - UIPanGestureRecognizer
- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //向右横扫返回上一层
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:{ //UIGestureRecognizerStateRecognized正常情况下只响应这个消息
            if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
                [[self navigationController] popViewControllerAnimated:YES];
                [self.view removeGestureRecognizer:gestureRecognizer];
            }
            break;
        }
        case UIGestureRecognizerStateFailed:{ //
            //NSLog(@"======UIGestureRecognizerStateFailed");
            break;
        }
        case UIGestureRecognizerStatePossible:{ //
            //NSLog(@"======UIGestureRecognizerStatePossible");
            break;
        }
        default:{
            break;
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"======handlePanGesture");
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:{ //UIGestureRecognizerStateRecognized正常情况下只响应这个消息
            //[self.view removeGestureRecognizer:gestureRecognizer];
            break;
        }
        case UIGestureRecognizerStateFailed:{ //
            //NSLog(@"======UIGestureRecognizerStateFailed");
            break;
        }
        case UIGestureRecognizerStatePossible:{ //
            //NSLog(@"======UIGestureRecognizerStatePossible");
            break;
        }
        default:{
            break;
        }
    }
}

- (void)handleGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    //点击显示或隐藏工具栏
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:{//正常情况下只响应这个消息
            
            if (self.isHide) {
                [self.navigationController setToolbarHidden:NO animated:YES];
                self.isHide = FALSE;
            }else{
                [self.navigationController setToolbarHidden:YES animated:YES];
                self.isHide = TRUE;
            }
            break;
        }
        case UIGestureRecognizerStateFailed:{ //
            //NSLog(@"======UIGestureRecognizerStateFailed");
            break;
        }
        case UIGestureRecognizerStatePossible:{ //
            //NSLog(@"======UIGestureRecognizerStatePossible");
            break;
        }
        default:{
            break;
        }
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //NSLog(@"handle touch");
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //NSLog(@"1");
    return YES;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"2");
    return YES;
}

#pragma mark - Memory management

- (void)dealloc {
    mainWebView.delegate = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - View lifecycle

- (void)loadView {
    mainWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mainWebView.delegate = self;
    mainWebView.scalesPageToFit = YES;
    if (self.htmlString != nil) {
        [mainWebView loadHTMLString:self.htmlString.content baseURL:self.URL];
    }else {
        [mainWebView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    }
    self.view = mainWebView;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    self.alerViewManager = [[AlerViewManager alloc] init];
    // 按键背景图片 plain模式
    favoriteBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    favoriteBarButton.frame = CGRectMake(5+(20+72)*2, 10, 20, 20);
    
    [favoriteBarButton setBackgroundImage:[UIImage imageNamed:@"Favorites-hollow.png"] forState:UIControlStateNormal];
    [favoriteBarButton addTarget:self action:@selector(goFavoriteClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //从standardDefaults中读取收藏列表
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData *udObject = [standardDefaults objectForKey:@"Favorites"];
    NSArray *udData = [NSKeyedUnarchiver unarchiveObjectWithData:udObject];// reverseObjectEnumerator] allObjects];
    self.articles = [NSMutableArray arrayWithArray:udData];
    //如果收藏列表里已经有,表示已经收藏
    if ([self.articles containsObject:self.htmlString]) {
        [self.favoriteBarButton setBackgroundImage:[UIImage imageNamed:@"Favorited.png"] forState:UIControlStateNormal];
    }else {//没有收藏
        [self.favoriteBarButton setBackgroundImage:[UIImage imageNamed:@"Favorites-hollow.png"] forState:UIControlStateNormal];
    }
    [self updateToolbarItems];
    self.view.backgroundColor = [UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    mainWebView = nil;
    popBarButtonItem = nil;
    favoriteBarButton = nil;
    favoriteBarButtonItem = nil;
    backBarButtonItem = nil;
    forwardBarButtonItem = nil;
    refreshBarButtonItem = nil;
    stopBarButtonItem = nil;
    actionBarButtonItem = nil;
    pageActionSheet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    NSAssert(self.navigationController, @"SVWebViewController needs to be contained in a UINavigationController. If you are presenting SVWebViewController modally, use SVModalWebViewController instead.",nil);
    
	[super viewWillAppear:animated];
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //[self.navigationController.navigationBar setAlpha:0.0f];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:NO animated:animated];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
            //IOS5
            if ([self.navigationController.toolbar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
                [self.navigationController.toolbar setBackgroundImage:[UIImage imageNamed:@"fot.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
            }
        }else {//IOS4
            
            [self.navigationController.toolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fot.png"]] atIndex:0];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //[self.navigationController.navigationBar setAlpha:1.0f];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Toolbar

- (void)updateToolbarItems {
    self.popBarButtonItem.enabled = YES;
    self.favoriteBarButtonItem.enabled = YES;
    self.favoriteBarButton.enabled = YES;
    [self.favoriteBarButton setShowsTouchWhenHighlighted:YES];
    self.backBarButtonItem.enabled = self.mainWebView.canGoBack;
    self.forwardBarButtonItem.enabled = self.mainWebView.canGoForward;
    self.actionBarButtonItem.enabled = YES;//!self.mainWebView.isLoading;卡在刷新的bug
    
    //UIBarButtonItem *refreshStopBarButtonItem = self.mainWebView.isLoading ? self.stopBarButtonItem : self.refreshBarButtonItem;
    UIBarButtonItem *refreshStopBarButtonItem = self.refreshBarButtonItem;
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 5.0f;
    UIBarButtonItem *fixedSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceItem.width = 40.0f;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];//UIBarButtonSystemItemFlexibleSpace
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray *items;
        CGFloat toolbarWidth = 250.0f;
        
        if(self.availableActions == 0) {
            toolbarWidth = 200.0f;
            items = [NSArray arrayWithObjects:
                     fixedSpace,
                     refreshStopBarButtonItem,
                     flexibleSpace,
                     self.backBarButtonItem,
                     flexibleSpace,
                     self.forwardBarButtonItem,
                     fixedSpace,
                     nil];
        } else {
            items = [NSArray arrayWithObjects:
                     fixedSpace,
                     refreshStopBarButtonItem,
                     flexibleSpace,
                     self.backBarButtonItem,
                     flexibleSpace,
                     self.forwardBarButtonItem,
                     flexibleSpace,
                     self.actionBarButtonItem,
                     fixedSpace,
                     nil];
        }
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, toolbarWidth, 44.0f)];
        toolbar.items = items;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    }
    
    else {
        NSArray *items;
        
        if(self.availableActions == 0) {
            if (self.htmlString != nil) {
                items = [NSArray arrayWithObjects:
                         fixedSpace,
                         self.popBarButtonItem,
                         flexibleSpace,
                         fixedSpace,
                         flexibleSpace,
                         fixedSpaceItem,
                         flexibleSpace,
                         nil];
            }
            else {
                items = [NSArray arrayWithObjects:
                         flexibleSpace,
                         self.backBarButtonItem,
                         flexibleSpace,
                         self.forwardBarButtonItem,
                         flexibleSpace,
                         refreshStopBarButtonItem,
                         flexibleSpace,
                         nil];
            }
        } else {
            if (self.htmlString != nil) {
                items = [NSArray arrayWithObjects:
                         fixedSpace,
                         self.popBarButtonItem,
                         flexibleSpace,
                         fixedSpaceItem,
                         flexibleSpace,
                         self.favoriteBarButtonItem,
                         flexibleSpace,
                         self.actionBarButtonItem,
                         fixedSpace,
                         nil];
            }
            else {
                items = [NSArray arrayWithObjects:
                         fixedSpace,
                         self.backBarButtonItem,
                         flexibleSpace,
                         self.forwardBarButtonItem,
                         flexibleSpace,
                         refreshStopBarButtonItem,
                         flexibleSpace,
                         self.actionBarButtonItem,
                         fixedSpace,
                         nil];
            }
        }
        
        self.toolbarItems = items;
        //[self.navigationController.toolbar addSubview:favoriteBarButton];
    }
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    //处理不同的URL
    if (inType == UIWebViewNavigationTypeLinkClicked) {
        //[[UIApplication sharedApplication] openURL:[inRequest URL]];
        //NSLog(@"host:%@\npath:%@",[[inRequest URL] host],[[inRequest URL] path]);
        //if ([[[inRequest URL] host] rangeOfString:@".appgame.com"].location != NSNotFound) {
        if (self.htmlString != nil) {
            NSLog(@"站内页面");
            SVWebViewController *viewController = [[SVWebViewController alloc] initWithURL:[inRequest URL]];
            [self.navigationController pushViewController:viewController animated:YES];
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self updateToolbarItems];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    //self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self updateToolbarItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateToolbarItems];
}

#pragma mark - Target actions

- (void)goPopClicked:(UIBarButtonItem *)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)goFavoriteClicked:(UIBarButtonItem *)sender {
    //从standardDefaults中读取收藏列表
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    //    NSData *udObject = [standardDefaults objectForKey:@"Favorites"];
    //    NSArray *udData = [NSKeyedUnarchiver unarchiveObjectWithData:udObject];
    //    self.articles = [NSMutableArray arrayWithArray:udData];
    
    //如果收藏列表里已经有,表示已经收藏,则取消收藏
    if ([self.articles containsObject:self.htmlString]) {
        [self.articles removeObject:self.htmlString];
        [self.favoriteBarButton setBackgroundImage:[UIImage imageNamed:@"Favorites-hollow.png"] forState:UIControlStateNormal];
        [self updateToolbarItems];
        [self.alerViewManager showOnlyMessage:@"取消收藏" inView:self.view];
    }else {//没有收藏,添加
        [self.articles addObject:self.htmlString];
        [self.favoriteBarButton setBackgroundImage:[UIImage imageNamed:@"Favorited.png"] forState:UIControlStateNormal];
        [self updateToolbarItems];
        [self.alerViewManager showOnlyMessage:@"收藏成功" inView:self.view];
        
    }
    NSData *dObject = [NSKeyedArchiver archivedDataWithRootObject:self.articles];
    [standardDefaults setObject:dObject forKey:@"Favorites"];
    [standardDefaults synchronize];
    
    //[self updateToolbarItems];
}

- (void)goBackClicked:(UIBarButtonItem *)sender {
    [mainWebView goBack];
}

- (void)goForwardClicked:(UIBarButtonItem *)sender {
    [mainWebView goForward];
}

- (void)reloadClicked:(UIBarButtonItem *)sender {
    [mainWebView reload];
}

- (void)stopClicked:(UIBarButtonItem *)sender {
    [mainWebView stopLoading];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self updateToolbarItems];
}

- (void)actionButtonClicked:(id)sender {
    
    if(pageActionSheet)
        return;
	
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        [self.pageActionSheet showFromBarButtonItem:self.actionBarButtonItem animated:YES];
//    else
//        [self.pageActionSheet showFromToolbar:self.navigationController.toolbar];
    
    //IADisquser *iaDisquser = [[IADisquser alloc] initWithIdentifier:@"disqus.com"];//path
    //CommentViewController *viewController = [[CommentViewController alloc] initWithTitle:self.htmlString.title withUrl:self.htmlString.articleURL.absoluteString];
    
    CommentViewController *viewController = [[CommentViewController alloc] initWithTitle:self.htmlString.title withUrl:[self.htmlString.articleURL absoluteString] threadID:[NSNumber numberWithInteger:-1]];
    
    [self.navigationController pushViewController:viewController animated:YES];    
}

- (void)doneButtonClicked:(id)sender {
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
	if([title isEqualToString:NSLocalizedString(@"在Safari中打开", @"")])
        [[UIApplication sharedApplication] openURL:self.mainWebView.request.URL];
    
    if([title isEqualToString:NSLocalizedString(@"复制链接", @"")]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.mainWebView.request.URL.absoluteString;
    }
    
    else if([title isEqualToString:NSLocalizedString(@"用邮件发送", @"")]) {
        
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        
		mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:[self.mainWebView stringByEvaluatingJavaScriptFromString:@"document.title"]];
  		[mailViewController setMessageBody:self.mainWebView.request.URL.absoluteString isHTML:NO];
		mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:mailViewController animated:YES completion:nil];
	}
    
    pageActionSheet = nil;
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end

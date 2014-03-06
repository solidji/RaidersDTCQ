//
//  HomeScrollView.m
//  RaidersDOTA
//
//  Created by 计 炜 on 13-6-8.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "HomeScrollView.h"
#import "Globle.h"
#import "HMSideMenu.h"

#import "UIImageView+AFNetworking.h"
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"

#import "ArticleItem.h"
#import "ArticleItemCell.h"
#import "SVWebViewController.h"
#import "DetailViewController.h"
#import "HomeViewController.h"
#import "SearchViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "SearchItemCell.h"
#import "RSSParser.h"
#import "RSSItem.h"

#define POSITIONID (int)scrollView.contentOffset.x/320

//按钮空隙
#define BUTTONGAP 10
//按钮长度
#define BUTTONWIDTH 59
//按钮宽度
#define BUTTONHEIGHT 30
//滑条CONTENTSIZEX
#define CONTENTSIZEX 320

#define BUTTONID (sender.tag-100)

//static CGFloat ImageHeight  = 150.0;
//static CGFloat ImageWidth  = 320.0;

@interface HomeScrollView ()
- (void)getArticles;//搜索文章
- (void)gotoSearch;//搜索文章
@property (nonatomic, strong) UIWebView *bbsWebView;
@property (nonatomic, assign) BOOL menuIsVisible;
@property (nonatomic, strong) HMSideMenu *sideMenu;
@end

@implementation HomeScrollView

@synthesize viewNameArray;
@synthesize nameArray,buttonImage,buttonBg;
@synthesize scrollViewSelectedChannelID;
@synthesize RootScrollView,TopScrollView,bgImage,bbsWebView,searchStr,searchView,articles;

@synthesize segmentedNews,segmentedEquip,segmentedFb,segmentedHero,segmentedNewer;
@synthesize newsGGViewController,newsHDViewController,newsHotViewController;
@synthesize newerGLViewController,newerJSViewController;
@synthesize heroGLViewController,heroCZViewController;
@synthesize fbDLViewController,fbGLViewController;
@synthesize zbDLViewController,zbHCViewController,zbTJViewController;
@synthesize heroHorizonViewController,thumbnailsViewController,customMosaicController;

#pragma mark - Class Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor whiteColor];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];
    self.RootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    self.RootScrollView.backgroundColor = [UIColor clearColor];
    self.viewNameArray = [NSArray arrayWithObjects:@"主页", @"资讯", @"新手", @"英雄", @"副本", @"装备",nil];
    self.RootScrollView.contentSize = CGSizeMake(320*[viewNameArray count], [Globle shareInstance].globleHeight-44-44);
    //self.RootScrollView.contentSize = CGSizeMake(320, frame.size.height+ImageHeight);        
    self.RootScrollView.pagingEnabled = YES;
    self.RootScrollView.userInteractionEnabled = YES;
    self.RootScrollView.bounces = NO;
    
    self.RootScrollView.showsHorizontalScrollIndicator = NO;
    self.RootScrollView.showsVerticalScrollIndicator = NO;
    self.RootScrollView.delegate = self;
    self.RootScrollView.tag = 1001;
    userContentOffsetX = 0;
    [self initWithViews];
    [self.view addSubview:self.RootScrollView];
    
    
    self.TopScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [Globle shareInstance].globleHeight-44-44, CONTENTSIZEX, 44)];
    self.TopScrollView.backgroundColor = [UIColor clearColor];
    self.TopScrollView.pagingEnabled = NO;
    self.TopScrollView.showsHorizontalScrollIndicator = NO;
    self.TopScrollView.showsVerticalScrollIndicator = NO;
    self.nameArray = [NSArray arrayWithObjects:@"主页", @"资讯", @"新手", @"英雄", @"副本", @"装备",nil];
    self.buttonImage = [NSArray arrayWithObjects:@"zhuye.png", @"zxzx.png", @"xsrm.png", @"yxzt.png", @"fbzl.png", @"zb.png", nil];//按钮小图标
    self.buttonBg = [NSArray arrayWithObjects:@"buttonbackground.png", @"buttonbackground.png", @"buttonbackground.png", @"buttonbackground.png", @"buttonbackground.png", @"buttonbackground.png", nil];//按钮背景
    self.TopScrollView.contentSize = CGSizeMake((BUTTONWIDTH+BUTTONGAP)*[self.nameArray count]+BUTTONGAP, 44);
    
    userSelectedChannelID = 100;
    scrollViewSelectedChannelID = 100;
    //self.TopScrollView.delegate = self;
    self.TopScrollView.tag = 1002;
    [self initWithNameButtons];
    [self.view addSubview:self.TopScrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //[self.navigationController.navigationBar setTranslucent:NO];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        //IOS5
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top.png"] forBarMetrics:UIBarMetricsDefault];
        //self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithTitle:(NSString *)title
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Initialization code        
        self.title = title;
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 26, 26);
        [leftButton setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
        [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setShowsTouchWhenHighlighted:YES];
        [leftButton addTarget:self action:@selector(gotoSearch) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *temporaryLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        temporaryLeftBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.rightBarButtonItem = temporaryLeftBarButtonItem;
    }
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [self.view addGestureRecognizer:singleTap];
        singleTap.delegate = self;
        singleTap.cancelsTouchesInView = NO;
    }
    self.searchStr = NULL;
    self.articles = [[NSMutableArray alloc] init];
    alerViewManager = [[AlerViewManager alloc] init];
    start = 0;
    receiveMember = 0;
    
    return self;
}

- (void)initWithViews
{
//    for (int i = 0; i < [viewNameArray count]; i++) {
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0+320*i, 0, 320, [Globle shareInstance].globleHeight-44-44)];
//        label.text = [NSString stringWithFormat:@"%@",[viewNameArray objectAtIndex:i]];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.font = [UIFont boldSystemFontOfSize:50.0];
//        label.backgroundColor = [UIColor clearColor];
//        [self.RootScrollView addSubview:label];
//    }
/*

    //设置第三页
    bbsWebView = [[UIWebView alloc] initWithFrame:CGRectMake(320*2, -88, 320, [Globle shareInstance].globleHeight)];
    //bbsWebView.delegate = self;
    bbsWebView.scalesPageToFit = YES;
    [bbsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://bbs.appgame.com/forum-120-1.html"]]];

    //在第三页上添加刷新与后退按钮
    UIView *twitterItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [twitterItem setMenuActionWithBlock:^{
        [bbsWebView goBack];
    }];
    UIImageView *twitterIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [twitterIcon setImage:[UIImage imageNamed:@"Retreat"]];
    [twitterItem addSubview:twitterIcon];
    
    UIView *emailItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [emailItem setMenuActionWithBlock:^{
        [bbsWebView goForward];
    }];
    UIImageView *emailIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [emailIcon setImage:[UIImage imageNamed:@"Advance"]];
    [emailItem addSubview:emailIcon];
    
//    UIView *facebookItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//    [facebookItem setMenuActionWithBlock:^{
//        [bbsWebView stopLoading];
//    }];
//    UIImageView *facebookIcon = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 35, 35)];
//    [facebookIcon setImage:[UIImage imageNamed:@"facebook"]];
//    [facebookItem addSubview:facebookIcon];
    
    UIView *browserItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [browserItem setMenuActionWithBlock:^{
        [bbsWebView reload];
    }];
    UIImageView *browserIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [browserIcon setImage:[UIImage imageNamed:@"Refresh"]];
    [browserItem addSubview:browserIcon];
    
    self.sideMenu = [[HMSideMenu alloc] initWithItems:@[twitterItem, emailItem, browserItem]];
    [self.sideMenu setItemSpacing:5.0f];
    [self.bbsWebView addSubview:self.sideMenu];
    [self.sideMenu open];
    
    [self.RootScrollView addSubview:bbsWebView];
*/
    
    
    //设置第一页
    customMosaicController = [[CustomMosaicController alloc] initWithTitle:@"热门文章" withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    [self addChildViewController:customMosaicController];
    //[customMosaicController.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    [customMosaicController.mosaicView setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    [self.RootScrollView addSubview:customMosaicController.view];
    [self.customMosaicController.view setHidden:NO];
    
    
    //设置第二页,最新资讯<热门推荐,论坛活动,游戏公告>
    segmentedNews = [[AKSegmentedControl alloc] initWithFrame:CGRectMake(320, 0, 320, 44)];
    segmentedNews.tag = 30002;
    [segmentedNews addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    // Setting the resizable background image
    UIImage *backgroundImage = [UIImage imageNamed:@"Subcategories.png"];
    [segmentedNews setBackgroundImage:backgroundImage];
    
    // Setting the behavior mode of the control
    [segmentedNews setSegmentedControlMode:AKSegmentedControlModeSticky];
    
    // Setting the separator image
    //[segmentedNews setSeparatorImage:[UIImage imageNamed:@"segmented-separator.png"]];
    
    UIImage *buttonBackgroundImagePressedCenter = [UIImage imageNamed:@"Subcategories-pressed.png"];//resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    
    // Button 1
    UIButton *button1 = [[UIButton alloc] init];
    [button1 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button1 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button1 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button1 setTitle:@"热门推荐" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    [button1.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    //[buttonSocial setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    // Button 2
    UIButton *button2 = [[UIButton alloc] init];
    [button2 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button2 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button2 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button2 setTitle:@"论坛活动" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button2.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    
    // Button 3
    UIButton *button3 = [[UIButton alloc] init];
    [button3 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button3 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button3 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button3 setTitle:@"游戏公告" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button3.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    
    // Setting the UIButtons used in the segmented control
    [segmentedNews setButtonsArray:@[button1, button2, button3]];
    [segmentedNews setSelectedIndex:0];
    //[buttonSocial setHighlighted:YES];
    // Adding your control to the view
    [self.RootScrollView addSubview:segmentedNews];
    
    newsHotViewController = [[HomeViewController alloc] initWithTitle:@"热门推荐" withUrl:@"re-men-wen-zhang"];
    //[self.RootScrollView addSubview:homeViewController.view];
    [self addChildViewController:newsHotViewController];
    [newsHotViewController.view setFrame:CGRectMake(320, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:newsHotViewController.view];
    [self.newsHotViewController.view setHidden:NO];
    
    newsHDViewController = [[HomeViewController alloc] initWithTitle:@"论坛活动" withUrl:@"activity"];
    //[self.RootScrollView addSubview:homeViewController.view];
    [self addChildViewController:newsHDViewController];
    [newsHDViewController.view setFrame:CGRectMake(320, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:newsHDViewController.view];
    [newsHDViewController.view setHidden:YES];
    
    newsGGViewController = [[HomeViewController alloc] initWithTitle:@"游戏公告" withUrl:@"announcement"];
    //[self.RootScrollView addSubview:homeViewController.view];
    [self addChildViewController:newsGGViewController];
    [newsGGViewController.view setFrame:CGRectMake(320, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:newsGGViewController.view];
    [newsGGViewController.view setHidden:YES];
    
    
    
    
    
    //设置第三页,新手入门<玩法介绍,新手攻略>
    segmentedNewer = [[AKSegmentedControl alloc] initWithFrame:CGRectMake(320*2, 0, 320, 44)];
    segmentedNewer.tag = 30003;
    [segmentedNewer addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    // Setting the resizable background image
    [segmentedNewer setBackgroundImage:backgroundImage];
    
    // Setting the behavior mode of the control
    [segmentedNewer setSegmentedControlMode:AKSegmentedControlModeSticky];
    
    // Button 1
    UIButton *button21 = [[UIButton alloc] init];
    [button21 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button21 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button21 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button21 setTitle:@"玩法介绍" forState:UIControlStateNormal];
    [button21 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    [button21.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    //[buttonSocial setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    // Button 2
    UIButton *button22 = [[UIButton alloc] init];
    [button22 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button22 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button22 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button22 setTitle:@"新手攻略" forState:UIControlStateNormal];
    [button22 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button22.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];

    // Setting the UIButtons used in the segmented control
    [segmentedNewer setButtonsArray:@[button21, button22]];
    [segmentedNewer setSelectedIndex:0];
    //[buttonSocial setHighlighted:YES];
    // Adding your control to the view
    [self.RootScrollView addSubview:segmentedNewer];
    
    newerJSViewController = [[HomeViewController alloc] initWithTitle:@"玩法介绍" withUrl:@"wan-fa-jie-shao"];
    [self addChildViewController:newerJSViewController];
    [newerJSViewController.view setFrame:CGRectMake(320*2, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:newerJSViewController.view];
    [self.newerJSViewController.view setHidden:NO];
    
    newerGLViewController = [[HomeViewController alloc] initWithTitle:@"新手攻略" withUrl:@"xin-shou-gong-lue"];
    [self addChildViewController:newerGLViewController];
    [newerGLViewController.view setFrame:CGRectMake(320*2, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:newerGLViewController.view];
    [newerGLViewController.view setHidden:YES];
    
    
    
    
    
    //设置第四页<英雄图鉴,英雄攻略,成长之路>
    segmentedHero = [[AKSegmentedControl alloc] initWithFrame:CGRectMake(320*3, 0, 320, 44)];
    segmentedHero.tag = 30004;
    [segmentedHero addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    // Setting the resizable background image
    [segmentedHero setBackgroundImage:backgroundImage];
    
    // Setting the behavior mode of the control
    [segmentedHero setSegmentedControlMode:AKSegmentedControlModeSticky];
    
    // Button 1
    UIButton *button31 = [[UIButton alloc] init];
    [button31 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button31 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button31 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button31 setTitle:@"英雄图鉴" forState:UIControlStateNormal];
    [button31 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    [button31.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    //[buttonSocial setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    // Button 2
    UIButton *button32 = [[UIButton alloc] init];
    [button32 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button32 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button32 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button32 setTitle:@"英雄攻略" forState:UIControlStateNormal];
    [button32 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button32.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    
    // Button 3
    UIButton *button33 = [[UIButton alloc] init];
    [button33 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button33 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button33 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button33 setTitle:@"成长之路" forState:UIControlStateNormal];
    [button33 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button33.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    
    // Setting the UIButtons used in the segmented control
    [segmentedHero setButtonsArray:@[button31, button32, button33]];
    [segmentedHero setSelectedIndex:0];
    // Adding your control to the view
    [self.RootScrollView addSubview:segmentedHero];
    
    heroHorizonViewController = [[HorizonViewController alloc] initWithTitle:@"英雄图鉴"];
    [self addChildViewController:heroHorizonViewController];
    [heroHorizonViewController.view setFrame:CGRectMake(320*3, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:heroHorizonViewController.view];
    [self.heroHorizonViewController.view setHidden:NO];
    
    heroGLViewController = [[HomeViewController alloc] initWithTitle:@"英雄攻略" withUrl:@"zhuanti-article"];
    [self addChildViewController:heroGLViewController];
    [heroGLViewController.view setFrame:CGRectMake(320*3, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:heroGLViewController.view];
    [heroGLViewController.view setHidden:YES];
    
    heroCZViewController = [[HomeViewController alloc] initWithTitle:@"成长之路" withUrl:@"chengzhangzhilu"];
    [self addChildViewController:heroCZViewController];
    [heroCZViewController.view setFrame:CGRectMake(320*3, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:heroCZViewController.view];
    [heroCZViewController.view setHidden:YES];

    
    
    
    
    //设置第五页<副本攻略,副本图鉴,副本掉落>
    segmentedFb = [[AKSegmentedControl alloc] initWithFrame:CGRectMake(320*4, 0, 320, 44)];
    segmentedFb.tag = 30005;
    [segmentedFb addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    // Setting the resizable background image
    [segmentedFb setBackgroundImage:backgroundImage];
    
    // Setting the behavior mode of the control
    [segmentedFb setSegmentedControlMode:AKSegmentedControlModeSticky];
    
    // Button 1
    UIButton *button41 = [[UIButton alloc] init];
    [button41 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button41 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button41 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button41 setTitle:@"副本攻略" forState:UIControlStateNormal];
    [button41 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    [button41.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    //[buttonSocial setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    // Button 2
    UIButton *button42 = [[UIButton alloc] init];
    [button42 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button42 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button42 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button42 setTitle:@"副本图鉴" forState:UIControlStateNormal];
    [button42 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button42.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    
    // Button 3
    UIButton *button43 = [[UIButton alloc] init];
    [button43 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button43 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button43 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button43 setTitle:@"副本掉落" forState:UIControlStateNormal];
    [button43 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button43.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    
    // Setting the UIButtons used in the segmented control
    [segmentedFb setButtonsArray:@[button41, button42, button43]];
    [segmentedFb setSelectedIndex:0];
    //[buttonSocial setHighlighted:YES];
    // Adding your control to the view
    [self.RootScrollView addSubview:segmentedFb];
    
    fbGLViewController = [[HomeViewController alloc] initWithTitle:@"副本攻略" withUrl:@"fu-ben-gong-lue"];
    [self addChildViewController:fbGLViewController];
    [fbGLViewController.view setFrame:CGRectMake(320*4, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:fbGLViewController.view];
    [fbGLViewController.view setHidden:NO];
    
    thumbnailsViewController = [[ASMediaThumbnailsViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:thumbnailsViewController];
    [thumbnailsViewController.view setFrame:CGRectMake(320*4, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:thumbnailsViewController.view];
    [thumbnailsViewController.view setHidden:YES];
    
    fbDLViewController = [[HomeViewController alloc] initWithTitle:@"副本掉落" withUrl:@"fu-ben-diao-luo"];
    [self addChildViewController:fbDLViewController];
    [fbDLViewController.view setFrame:CGRectMake(320*4, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:fbDLViewController.view];
    [fbDLViewController.view setHidden:YES];
    
    
    
    
    //设置第六页
    segmentedEquip = [[AKSegmentedControl alloc] initWithFrame:CGRectMake(320*5, 0, 320, 44)];
    segmentedEquip.tag = 30006;
    [segmentedEquip addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    // Setting the resizable background image
    [segmentedEquip setBackgroundImage:backgroundImage];
    
    // Setting the behavior mode of the control
    [segmentedEquip setSegmentedControlMode:AKSegmentedControlModeSticky];
    
    // Button 1
    UIButton *button51 = [[UIButton alloc] init];
    [button51 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button51 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button51 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button51 setTitle:@"装备合成" forState:UIControlStateNormal];
    [button51 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    [button51.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    //[buttonSocial setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    // Button 2
    UIButton *button52 = [[UIButton alloc] init];
    [button52 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button52 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button52 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button52 setTitle:@"装备掉落" forState:UIControlStateNormal];
    [button52 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button52.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    
    // Button 3
    UIButton *button53 = [[UIButton alloc] init];
    [button53 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [button53 setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [button53 setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [button53 setTitle:@"装备推荐" forState:UIControlStateNormal];
    [button53 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button53.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0]];
    
    // Setting the UIButtons used in the segmented control
    [segmentedEquip setButtonsArray:@[button51, button52, button53]];
    [segmentedEquip setSelectedIndex:0];
    //[buttonSocial setHighlighted:YES];
    // Adding your control to the view
    [self.RootScrollView addSubview:segmentedEquip];
    
    zbHCViewController = [[HomeViewController alloc] initWithTitle:@"装备合成" withUrl:@"zhuang-bei-he-cheng"];
    [self addChildViewController:zbHCViewController];
    [zbHCViewController.view setFrame:CGRectMake(320*5, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:zbHCViewController.view];
    [zbHCViewController.view setHidden:NO];
    
    zbDLViewController = [[HomeViewController alloc] initWithTitle:@"装备掉落" withUrl:@"zhuang-bei-diao-luo"];
    [self addChildViewController:zbDLViewController];
    [zbDLViewController.view setFrame:CGRectMake(320*5, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:zbDLViewController.view];
    [zbDLViewController.view setHidden:YES];
    
    zbTJViewController = [[HomeViewController alloc] initWithTitle:@"装备掉落" withUrl:@"zhuang-bei-zhan-wei"];
    [self addChildViewController:zbTJViewController];
    [zbTJViewController.view setFrame:CGRectMake(320*5, 44, 320, [Globle shareInstance].globleHeight-44-44-44)];
    [self.RootScrollView addSubview:zbTJViewController.view];
    [zbTJViewController.view setHidden:YES];
    
    
    
    
    //设置第七页<搜索>
    //设置搜索页
    
//    searchView = [[UITableView alloc] initWithFrame:CGRectMake(320.0*6, 0, 320, [Globle shareInstance].globleHeight) style:UITableViewStylePlain];
    
//    searchView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(320.0*6, 0, self.view.bounds.size.width,[Globle shareInstance].globleHeight) withType: withStateViews];
//    self.searchView.tag = 100000;
//    
//    [self.searchView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
//    searchView.delegate = self;
//    searchView.dataSource = self;
//    searchView.allowsSelection = YES;
//    searchView.backgroundColor = [UIColor clearColor];
//    searchView.backgroundColor = [UIColor colorWithRed:211.0f/255.0f green:214.0f/255.0f blue:219.0f/255.0f alpha:0.7f];
//    searchView.separatorStyle = UITableViewCellSeparatorStyleNone;//选中时cell样式
//    searchView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    [searchView setHidden:NO];
//    //searchView.alpha = 0.7f;
//    [self.RootScrollView addSubview:searchView];
//    
//    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(320.0*6, 0.0, self.view.bounds.size.width, 40)];
//    _searchBar.placeholder=@"玩游戏卡住了?搜一下!";
//    _searchBar.delegate = self;
//    _searchBar.showsCancelButton = NO;
//    _searchBar.barStyle=UIBarStyleDefault;
//    _searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
//    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
//    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    [self.RootScrollView addSubview:_searchBar];
    
    
    //searchView.tableHeaderView = _searchBar;
    //[self.view addSubview:_searchBar];
    //修改UISearchBar的背景颜色
    //[[_searchBar.subviews objectAtIndex:0]removeFromSuperview];
    
    //    _searchBar.backgroundColor=[UIColor colorWithRed:(202.0f/255.0f) green:(41.0f/255.0f) blue:(52.0f/255.0f) alpha:1.0f];
    //    for (UIView *subview in _searchBar.subviews)
    //    {
    //        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
    //        {
    //            [subview removeFromSuperview];
    //            break;
    //        }
    //    }
    //为UISearchBar添加背景图片
//    UIImageView *searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Subcategories.png"]];
//    searchImage.contentMode = UIViewContentModeScaleAspectFill;
//    searchImage.frame = _searchBar.frame;
//    UIView *segment = [_searchBar.subviews objectAtIndex:0];
//    [segment addSubview:searchImage];
}

#pragma mark - AKSegmentedControl callbacks

- (void)segmentedControlValueChanged:(id)sender
{
    AKSegmentedControl *segmented = (AKSegmentedControl *)sender;
    NSLog(@"SegmentedControl : Selected Index %@,%d", [segmented selectedIndexes], segmented.tag);
    if (segmented.tag == 30002) {
        if ([segmented selectedIndexes].firstIndex == 0) {
            [self.newsHotViewController.view setHidden:NO];
            [self.newsHDViewController.view setHidden:YES];
            [self.newsGGViewController.view setHidden:YES];
        }else if ([segmented selectedIndexes].firstIndex == 1){
            [self.newsHotViewController.view setHidden:YES];
            [self.newsHDViewController.view setHidden:NO];
            [self.newsGGViewController.view setHidden:YES];
        }else {
            [self.newsHotViewController.view setHidden:YES];
            [self.newsHDViewController.view setHidden:YES];
            [self.newsGGViewController.view setHidden:NO];
        }
    }else if (segmented.tag == 30003) {
        if ([segmented selectedIndexes].firstIndex == 0) {
            [self.newerJSViewController.view setHidden:NO];
            [self.newerGLViewController.view setHidden:YES];
        }else if ([segmented selectedIndexes].firstIndex == 1){
            [self.newerJSViewController.view setHidden:YES];
            [self.newerGLViewController.view setHidden:NO];
        }
    }else if (segmented.tag == 30004) {
        if ([segmented selectedIndexes].firstIndex == 0) {
            [self.heroHorizonViewController.view setHidden:NO];
            [self.heroGLViewController.view setHidden:YES];
            [self.heroCZViewController.view setHidden:YES];
        }else if ([segmented selectedIndexes].firstIndex == 1) {
            [self.heroHorizonViewController.view setHidden:YES];
            [self.heroGLViewController.view setHidden:NO];
            [self.heroCZViewController.view setHidden:YES];
        }else if ([segmented selectedIndexes].firstIndex == 2){
            [self.heroHorizonViewController.view setHidden:YES];
            [self.heroGLViewController.view setHidden:YES];
            [self.heroCZViewController.view setHidden:NO];
        }
    }else if (segmented.tag == 30005) {
        if ([segmented selectedIndexes].firstIndex == 0) {
            [self.fbGLViewController.view setHidden:NO];
            [self.thumbnailsViewController.view setHidden:YES];
            [self.fbDLViewController.view setHidden:YES];
        }else if ([segmented selectedIndexes].firstIndex == 1) {
            [self.fbGLViewController.view setHidden:YES];
            [self.thumbnailsViewController.view setHidden:NO];
            [self.fbDLViewController.view setHidden:YES];
        }else if ([segmented selectedIndexes].firstIndex == 2){
            [self.fbGLViewController.view setHidden:YES];
            [self.thumbnailsViewController.view setHidden:YES];
            [self.fbDLViewController.view setHidden:NO];
        }
    }else if (segmented.tag == 30006) {
        if ([segmented selectedIndexes].firstIndex == 0) {
            [self.zbHCViewController.view setHidden:NO];
            [self.zbDLViewController.view setHidden:YES];
            [self.zbTJViewController.view setHidden:YES];
        }else if ([segmented selectedIndexes].firstIndex == 1){
            [self.zbHCViewController.view setHidden:YES];
            [self.zbDLViewController.view setHidden:NO];
            [self.zbTJViewController.view setHidden:YES];
        }else {
            [self.zbHCViewController.view setHidden:YES];
            [self.zbDLViewController.view setHidden:YES];
            [self.zbTJViewController.view setHidden:NO];
        }
    }
}

#pragma mark - ScrollView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.tag == 1001){
        userContentOffsetX = scrollView.contentOffset.x;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 1001){
        if (userContentOffsetX < scrollView.contentOffset.x) {
            isLeftScroll = YES;
        }
        else {
            isLeftScroll = NO;
        }
        
        //橡皮筋效果
//        CGFloat yOffset   = self.RootScrollView.contentOffset.y;
//        
//        if (yOffset < 0) {
//            
//            CGFloat factor = ((ABS(yOffset)+ImageHeight)*ImageWidth)/ImageHeight;
//            CGRect f = CGRectMake(-(factor-ImageWidth)/2, 0, factor, ImageHeight+ABS(yOffset));
//            self.imgProfile.frame = f;
//        } else {
//            CGRect f = self.imgProfile.frame;
//            f.origin.y = -yOffset;
//            self.imgProfile.frame = f;
//        }
        
    }else if (scrollView.tag == 100000){
        [searchView tableViewDidDragging];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.tag == 100000) {
        NSInteger returnKey = [searchView tableViewDidEndDragging];
        
        //  returnKey用来判断执行的拖动是下拉还是上拖，如果数据正在加载，则返回DO_NOTHING
        if (returnKey != k_RETURN_DO_NOTHING)
        {
            NSString * key = [NSString stringWithFormat:@"%d", returnKey];
            [NSThread detachNewThreadSelector:@selector(updateThread:) toTarget:self withObject:key];
        }
        
        if (!decelerate)
        {
            //[self loadImagesForOnscreenRows];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 1001){
        //调整顶部滑条按钮状态
        [self adjustTopScrollViewButton:scrollView];
        
        if (isLeftScroll) {
            if (scrollView.contentOffset.x <= 320*3) {
                [self.TopScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
            else {
                [self.TopScrollView setContentOffset:CGPointMake((POSITIONID-4)*64+45, 0) animated:YES];
            }
            
        }
        else {
            if (scrollView.contentOffset.x >= 320*3) {
                [self.TopScrollView setContentOffset:CGPointMake(2*64+45, 0) animated:YES];
            }
            else {
                [self.TopScrollView setContentOffset:CGPointMake(POSITIONID*64, 0) animated:YES];
            }
        }
    }
}

- (void)adjustTopScrollViewButton:(UIScrollView *)scrollView
{
    [self setButtonUnSelect];
    self.scrollViewSelectedChannelID = POSITIONID+100;
    [self setButtonSelect];
}


#pragma mark -
#pragma mark - Table View control

- (void)updateThread:(NSString *)returnKey{
    @autoreleasepool {
        sleep(2);
        switch ([returnKey intValue]) {
            case k_RETURN_REFRESH:
            {
                [articles removeAllObjects];
                start = 0;
                [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
                
                break;
            }
            case k_RETURN_LOADMORE:
            {
                start = [self.articles count]/10 + 1;
                
                [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
                break;
            }
            default:
                break;
        }
    }
    [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
}

- (void)updateThreadHotkey:(NSString *)returnKey{
    @autoreleasepool {
        sleep(2);
        switch ([returnKey intValue]) {
            case k_RETURN_REFRESH:
            {
                [articles removeAllObjects];
                start = 0;
                [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
                
                break;
            }
            default:
                break;
        }
    }
    [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
}

- (void)updateTableView
{
    if (receiveMember  >= 10)
    {
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果数据还能继续加载，则传入NO
        [searchView reloadData:NO];
    }
    else
    {
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果已全部加载，则传入YES
        [searchView reloadData:YES];
    }
}

#pragma mark -
#pragma mark - UITableViewDelegate

//某一行被选中,由ViewController来实现push详细页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.articles count] > indexPath.row) {
        ArticleItem *aArticle = [self.articles objectAtIndex:indexPath.row];
        SVWebViewController *viewController = [[SVWebViewController alloc] initWithHTMLString:aArticle URL:aArticle.articleURL];
        
        //NSLog(@"didSelectArticle:%@",aArticle.content);
        [self.navigationController pushViewController:viewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSString *article = [(ArticleItem *)[self.articles objectAtIndex:indexPath.row] description];
    //    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000);
    //    CGSize size = [article sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    return 53;//计算每一个cell的高度
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([articles count] == 0) {
        //  本方法是为了在数据为空时，让“下拉刷新”视图可直接显示，比较直观
        tableView.contentInset = UIEdgeInsetsMake(k_STATE_VIEW_HEIGHT, 0, 0, 0);
    }
    return MAX(10, [articles count]);

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    SearchItemCell *cell = (SearchItemCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SearchItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    // Leave cells empty if there's no data yet
    if ([self.articles count] > 0) {
        // Set up the cell...
        if (indexPath.row+1 > [self.articles count]) {
            cell.nameLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"IconPlaceholder.png"];
            [cell.imageView setHidden:YES];
        }else {
            ArticleItem *aArticle = [self.articles objectAtIndex:indexPath.row];
            cell.nameLabel.text = aArticle.title;
            [cell.imageView setImageWithURL:aArticle.iconURL
                           placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
            
            [cell.nameLabel setFrame:CGRectMake(8.0, 16.0, 320.0-16.0, 20.0)];
            [cell.imageView setHidden:YES];
        }
    }else {
        cell.nameLabel.text = @"";
        cell.imageView.image = [UIImage imageNamed:@"IconPlaceholder.png"];
        [cell.imageView setHidden:YES];
    }

    return cell;
}


#pragma mark -
#pragma mark searchbar Delegate
- (void)doSearch:(UISearchBar *)searchBar{
    //取消UISearchBar调用的键盘
    [searchBar resignFirstResponder];
    //[searchView setHidden:NO];
    
    [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
}

/*取消按钮*/
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //取消UISearchBar调用的键盘
    [searchBar resignFirstResponder];
    self.searchStr = @"";
    [searchBar setText:self.searchStr];
    //[searchView setHidden:YES];
    [self.RootScrollView setContentOffset:CGPointMake((userSelectedChannelID-100)*320, 0) animated:YES];
}

/*键盘搜索按钮*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self doSearch:searchBar];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarShouldBeginEditing");
    searchBar.showsCancelButton = YES;
    //改变UISearchBar取消按钮字体
    for(id cc in [searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            //btn.buttonType = UIButtonTypeCustom;
            //btn.frame = CGRectMake(0, 0, 55, 30);
            [btn setTitle:@"取消" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn setTintColor:[UIColor colorWithRed:(35.0f/255.0f) green:(127.0f/255.0f) blue:(187.0f/255.0f) alpha:1.0f]];
            //[btn setBackgroundImage:[UIImage imageNamed:@"Cancel.png"] forState:UIControlStateNormal];
            //[btn setBackgroundImage:[UIImage imageNamed:@"Cancel-gray.png"] forState:UIControlStateHighlighted];
        }
    }
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarShouldEndEditing");
    searchBar.showsCancelButton = NO;
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarTextDidBeginEditing");
    //itunesAppnamesTableView.frame = CGRectMake(0, 40, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-40-20-44);
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarTextDidEndEditing");
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //NSLog(@"textDidChange:%@", searchText);
    self.searchStr = searchText;
}

- (void)getArticles {
    // start activity indicator
    //[[self indicator] startAnimating];
    //[self.pullToRefreshTableView setAlpha:0.5];
    //[pullToRefreshTableView setHidden:YES];
    [alerViewManager showMessage:@"正在加载数据" inView:self.view];
    
    NSMutableArray *article = [NSMutableArray array];
    NSString *urlString =  [NSString stringWithFormat:@"http://dt.appgame.com/feed?paged=%d&s=%@", start, self.searchStr];
    if (self.searchStr == nil) {
        urlString = [NSString stringWithFormat:@"http://dt.appgame.com/feed?paged=%d", start];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [RSSParser parseRSSFeedForRequest:request success:^(NSArray *feedItems) {
        
        //you get an array of RSSItem
        receiveMember = [feedItems count];
        if (receiveMember > 0) {
            for (RSSItem *feedItem in feedItems) {
                ArticleItem *articleItem = [[ArticleItem alloc] init];
                articleItem.title = [feedItem.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                articleItem.description = feedItem.itemDescription;
                articleItem.creator = feedItem.author;
                articleItem.pubDate = feedItem.pubDate;
                articleItem.content = feedItem.content;
                articleItem.articleURL = feedItem.link;
                articleItem.category = @"";
                
                if ([feedItem imagesFromItemDescription].count != 0) {
                    NSMutableString *iconURL = [NSMutableString stringWithString:[[feedItem imagesFromItemDescription] objectAtIndex:0]];
                    //[iconURL insertString:@"-150x150" atIndex:[[[feedItem imagesFromItemDescription] objectAtIndex:0] length]-4];
                    //NSLog(@"title  :%@", feedItem.title);
                    //NSLog(@"iconURL:%@", iconURL);
                    //中文URL编码
                    articleItem.iconURL = [NSURL URLWithString:[iconURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
                else
                {
                    articleItem.iconURL = [NSURL URLWithString:@"IconPlaceholder.png"];
                }
                
                //过滤掉description里的缩略图与content里的android与winphone图片
                NSError *error;
                
                NSRegularExpression *regexThumbnail = [NSRegularExpression
                                                       regularExpressionWithPattern:@"(<div><img).*(https?)\\S*(png|jpg|jpeg|gif).*(<div.*</div>)*.*(</div>)"
                                                       options:NSRegularExpressionCaseInsensitive
                                                       error:&error];
                if (feedItem.itemDescription != nil) {
                    [regexThumbnail enumerateMatchesInString:feedItem.itemDescription
                                                     options:0
                                                       range:NSMakeRange(0, feedItem.itemDescription.length)
                                                  usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                                      //[imagesURLStringArray addObject:[feedItem.itemDescription substringWithRange:result.range]];
                                                      articleItem.description = [articleItem.description stringByReplacingOccurrencesOfString:[feedItem.itemDescription substringWithRange:result.range] withString:@""];
                                                      
                                                      articleItem.content = [articleItem.content stringByReplacingOccurrencesOfString:[feedItem.itemDescription substringWithRange:result.range] withString:@""];
                                                      
                                                      //NSLog(@"des:%@,%@",articleItem.description,[feedItem.itemDescription substringWithRange:result.range]);
                                                  }];
                }
                NSRegularExpression *regexAndroid = [NSRegularExpression
                                                     regularExpressionWithPattern:@"(<div.*\\n*.*)(www\\.appgame\\.com/source/html5/images/appgame-download-android-s2\\.png|www\\.appgame\\.com/source/html5/images/appgame-download-wphone\\.png).*\\n*.*(<div.*\\n*.*</div>)*.*\\n*.*(</div>)"
                                                     options:NSRegularExpressionCaseInsensitive
                                                     error:&error];
                if (feedItem.content != nil) {
                    [regexAndroid enumerateMatchesInString:feedItem.content
                                                   options:0
                                                     range:NSMakeRange(0, feedItem.content.length)
                                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                                    articleItem.content = [articleItem.content stringByReplacingOccurrencesOfString:[feedItem.content substringWithRange:result.range] withString:@""];
                                                    
                                                    NSLog(@"content:%@,%@",articleItem.content,[feedItem.content substringWithRange:result.range]);
                                                }];
                }
                //return [NSArray arrayWithArray:imagesURLStringArray];
                if (articleItem.content != nil) {
                    NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"appgame" ofType:@"html"];
                    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
                    NSString *contentHtml = @"";
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
                    contentHtml = [contentHtml stringByAppendingFormat:htmlString,
                                   articleItem.title, @" ", [dateFormatter stringFromDate:articleItem.pubDate]];
                    contentHtml = [contentHtml stringByReplacingOccurrencesOfString:@"<!--content-->" withString:articleItem.content];
                    articleItem.content = contentHtml;
                }
                [article addObject:articleItem];
            }
            if (start < 2) {
                [self.articles removeAllObjects];

                self.articles = article;
                
                [alerViewManager dismissMessageView:self.view];
            }
            else
            {
                for (ArticleItem *articleItem in article) {
                    [self.articles addObject:articleItem];
                }
                [alerViewManager dismissMessageView:self.view];
            }
        }
        else
        {
            [alerViewManager dismissMessageView:self.view];
            //[alerViewManager showOnlyMessage:@"暂无更多数据" inView:self.view];
        }
        //self.articles = [[articles reverseObjectEnumerator] allObjects];

        // reload the table
        [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
        
    } failure:^(NSError *error) {
        
        //something went wrong
        NSLog(@"Failure: %@", error);
        [alerViewManager dismissMessageView:self.view];
        [alerViewManager showOnlyMessage:@"请求数据失败" inView:self.view];
        
        //        if([self.articles count] == 0) {
        //            ifNeedFristLoading = YES;
        //        }
        
        [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
        
        // alert the error
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Occured"
        //                                                        message:[error localizedDescription]
        //                                                       delegate:nil
        //                                              cancelButtonTitle:@"OK"
        //                                              otherButtonTitles:nil];
        //        [alert show];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)gotoSearch{
    //设置搜索页出现
    //[self.RootScrollView setContentOffset:CGPointMake(6*320, 0) animated:YES];
    SearchViewController *searchController = [[SearchViewController alloc] initWithTitle:@"搜索" withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    
    [self.navigationController pushViewController:searchController animated:YES];
}

- (void)initWithNameButtons
{
    shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 59, 44)];
    [shadowImageView setImage:[UIImage imageNamed:@"red_line_and_shadow.png"]];
    [shadowImageView setAlpha:0.0];
    [self.TopScrollView addSubview:shadowImageView];
    
    for (int i = 0; i < [self.nameArray count]; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(BUTTONGAP+(BUTTONGAP+BUTTONWIDTH)*i, 24, 37, 15)];
        [button setTag:i+100];
                
        //清除按钮上的颜色
        [button setBackgroundColor:[UIColor clearColor]];
        
        //这段是给按钮图标添加按下效果
        NSString *imageNormal = [NSString stringWithFormat:@"%@",[self.buttonBg objectAtIndex:i]];
        NSMutableString* imageHighlighted = [NSMutableString stringWithString:imageNormal];
        [imageHighlighted insertString:@"-highlighted" atIndex:(imageNormal.length-4)];
        
        //设置按钮的图片
        UIImage *buttonImageNormal = [UIImage imageNamed:imageNormal];
        [button setBackgroundImage:buttonImageNormal
                          forState:UIControlStateNormal];
        UIImage *buttonImagePressed = [UIImage imageNamed:imageHighlighted];
        [button setBackgroundImage:buttonImagePressed 
                          forState:UIControlStateHighlighted];
        button.contentMode= UIViewContentModeCenter;

    
        //设置按钮上的文字
        [button setTitle:[NSString stringWithFormat:@"%@",[self.nameArray objectAtIndex:i]] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"%@",[self.nameArray objectAtIndex:i]] forState:UIControlStateHighlighted];
        //设置按钮上文字的大小和颜色
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        //button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        //button.titleLabel.font = [UIFont fontWithName:@"DFPHaiBaoW12" size:20.0];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:13.0];
        
        //[button setTitleColor:[Globle colorFromHexRGB:@"868686"] forState:UIControlStateNormal];
        //[button setTitleColor:[Globle colorFromHexRGB:@"bb0b15"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectNameButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.TopScrollView addSubview:button];
        
        //设置按钮顶部的图标
        NSString *image = [NSString stringWithFormat:@"%@",[self.buttonImage objectAtIndex:i]];
        NSMutableString *imageSelected = [NSMutableString stringWithString:image];
        [imageSelected insertString:@"-highlighted" atIndex:(image.length-4)];
        
        UIImageView *btImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
        btImage.contentMode= UIViewContentModeCenter;
        [btImage setFrame:CGRectMake(BUTTONGAP+(BUTTONGAP+BUTTONWIDTH)*i, 2, 37, 20)];
        [btImage setTag:i+10000];
        [self.TopScrollView addSubview:btImage];
        
        if (i == 0) {
            button.selected = YES;
            [button setBackgroundImage:buttonImagePressed
                              forState:UIControlStateNormal];
            
            btImage.image = [UIImage imageNamed:imageSelected];
        }
    }
}

- (void)selectNameButton:(UIButton *)sender
{
    [self adjustScrollViewContentX:sender];
    
    //如果更换按钮
    if (sender.tag != userSelectedChannelID) {
        //取之前的按钮
        UIButton *lastButton = (UIButton *)[self.TopScrollView viewWithTag:userSelectedChannelID];
        lastButton.selected = NO;

        NSString *imageNormal = [NSString stringWithFormat:@"%@",[self.buttonBg objectAtIndex:(userSelectedChannelID-100)]];
        NSMutableString* imageHighlighted = [NSMutableString stringWithString:imageNormal];
        [imageHighlighted insertString:@"-highlighted" atIndex:(imageNormal.length-4)];
        UIImage *buttonImageNormal = [UIImage imageNamed:imageNormal];
        [lastButton setBackgroundImage:buttonImageNormal
                          forState:UIControlStateNormal];
        
        UIImageView *lastImg = (UIImageView *)[self.TopScrollView viewWithTag:(userSelectedChannelID-100+10000)];
        NSString *image = [NSString stringWithFormat:@"%@",[self.buttonImage objectAtIndex:(userSelectedChannelID-100)]];
        NSMutableString *imageSelected = [NSMutableString stringWithString:image];
        [imageSelected insertString:@"-highlighted" atIndex:(image.length-4)];
        
        lastImg.image = [UIImage imageNamed:image];

        //赋值按钮ID
        userSelectedChannelID = sender.tag;
    }
    
    //按钮选中状态
    if (!sender.selected) {
        sender.selected = YES;
        
        NSString *imageNormal = [NSString stringWithFormat:@"%@",[self.buttonBg objectAtIndex:(userSelectedChannelID-100)]];
        NSMutableString* imageHighlighted = [NSMutableString stringWithString:imageNormal];
        [imageHighlighted insertString:@"-highlighted" atIndex:(imageNormal.length-4)];
        UIImage *buttonImagePressed = [UIImage imageNamed:imageHighlighted];
        [sender setBackgroundImage:buttonImagePressed
                              forState:UIControlStateNormal];
        
        UIImageView *nowImg = (UIImageView *)[self.TopScrollView viewWithTag:(userSelectedChannelID-100+10000)];
        NSString *image = [NSString stringWithFormat:@"%@",[self.buttonImage objectAtIndex:(userSelectedChannelID-100)]];
        NSMutableString *imageSelected = [NSMutableString stringWithString:image];
        [imageSelected insertString:@"-highlighted" atIndex:(image.length-4)];
        
        nowImg.image = [UIImage imageNamed:imageSelected];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            [shadowImageView setFrame:CGRectMake(sender.frame.origin.x, 0, 59, 44)];
            
        } completion:^(BOOL finished) {
            if (finished) {
                //设置新闻页出现
                [self.RootScrollView setContentOffset:CGPointMake(BUTTONID*320, 0) animated:NO];
                //赋值滑动列表选择频道ID
                scrollViewSelectedChannelID = sender.tag;
            }
        }];
        
    }
    //重复点击选中按钮
    else {
        
    }
}

- (void)adjustScrollViewContentX:(UIButton *)sender
{
    if (sender.frame.origin.x - self.TopScrollView.contentOffset.x > CONTENTSIZEX-(BUTTONGAP+BUTTONWIDTH)) {
        [self.TopScrollView setContentOffset:CGPointMake((BUTTONID-4)*(BUTTONGAP+BUTTONWIDTH)+45, 0)  animated:YES];
    }
    
    if (sender.frame.origin.x - self.TopScrollView.contentOffset.x < 5) {
        [self.TopScrollView setContentOffset:CGPointMake(BUTTONID*(BUTTONGAP+BUTTONWIDTH), 0)  animated:YES];
    }
}

- (void)setButtonUnSelect
{
    //滑动撤销选中按钮
    UIButton *lastButton = (UIButton *)[self.TopScrollView viewWithTag:scrollViewSelectedChannelID];
    lastButton.selected = NO;
    
    NSString *imageNormal = [NSString stringWithFormat:@"%@",[self.buttonBg objectAtIndex:(scrollViewSelectedChannelID-100)]];
    NSMutableString* imageHighlighted = [NSMutableString stringWithString:imageNormal];
    [imageHighlighted insertString:@"-highlighted" atIndex:(imageNormal.length-4)];
    UIImage *buttonImageNormal = [UIImage imageNamed:imageNormal];
    [lastButton setBackgroundImage:buttonImageNormal
                          forState:UIControlStateNormal];
    
    UIImageView *lastImg = (UIImageView *)[self.TopScrollView viewWithTag:(scrollViewSelectedChannelID-100+10000)];
    NSString *image = [NSString stringWithFormat:@"%@",[self.buttonImage objectAtIndex:(scrollViewSelectedChannelID-100)]];
    NSMutableString *imageSelected = [NSMutableString stringWithString:image];
    [imageSelected insertString:@"-highlighted" atIndex:(image.length-4)];
    
    lastImg.image = [UIImage imageNamed:image];
}

- (void)setButtonSelect
{
    //滑动选中按钮
    UIButton *button = (UIButton *)[self.TopScrollView viewWithTag:scrollViewSelectedChannelID];
    
    NSString *imageNormal = [NSString stringWithFormat:@"%@",[self.buttonBg objectAtIndex:(scrollViewSelectedChannelID-100)]];
    NSMutableString* imageHighlighted = [NSMutableString stringWithString:imageNormal];
    [imageHighlighted insertString:@"-highlighted" atIndex:(imageNormal.length-4)];
    UIImage *buttonImagePressed = [UIImage imageNamed:imageHighlighted];
    [button setBackgroundImage:buttonImagePressed
                      forState:UIControlStateNormal];

    UIImageView *nowImg = (UIImageView *)[self.TopScrollView viewWithTag:(scrollViewSelectedChannelID-100+10000)];
    NSString *image = [NSString stringWithFormat:@"%@",[self.buttonImage objectAtIndex:(scrollViewSelectedChannelID-100)]];
    NSMutableString *imageSelected = [NSMutableString stringWithString:image];
    [imageSelected insertString:@"-highlighted" atIndex:(image.length-4)];
    
    nowImg.image = [UIImage imageNamed:imageSelected];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [shadowImageView setFrame:CGRectMake(button.frame.origin.x, 0, 59, 44)];
        
    } completion:^(BOOL finished) {
        if (finished) {
            if (!button.selected) {
                button.selected = YES;
                userSelectedChannelID = button.tag;
            }
        }
    }];
    
}

#pragma mark - UIPanGestureRecognizer

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    //        UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:{ // UIGestureRecognizerStateRecognized = UIGestureRecognizerStateEnded // 正常情况下只响应这个消息
            if (self.sideMenu.isOpen)
                [self.sideMenu close];
            else
                [self.sideMenu open];
            //            NSLog(@"======UIGestureRecognizerStateEnded || UIGestureRecognizerStateRecognized");
            
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

@end

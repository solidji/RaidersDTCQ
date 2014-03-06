//
//  HomeTabViewController.m
//  RaidersSD
//
//  Created by 计 炜 on 13-8-28.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "HomeTabViewController.h"
#import "SVWebViewController.h"
#import "doubleWebViewController.h"
#import "HMSideMenu.h"
#import "SearchViewController.h"
#import "Globle.h"

#import "CustomTabItem.h"
#import "CustomSelectionView.h"
#import "CustomBackgroundLayer.h"
#import "CustomNoiseBackgroundView.h"
#import "UIView+Positioning.h"

//@implementation UINavigationBar (CustomHeight)
//- (CGSize)sizeThatFits:(CGSize)size {
//    // Change navigation bar height. The height must be even, otherwise there will be a white line above the navigation bar.
//    CGSize newSize = CGSizeMake(self.frame.size.width, 40);
//    return newSize;
//}
//
//-(void)layoutSubviews {
//    [super layoutSubviews];
//    
//    CGRect barFrame = self.frame;
//    barFrame.size.height = 40;
//    self.frame = barFrame;
//    
//    // Make items on navigation bar vertically centered.
//    int i = 0;
//    for (UIView *view in self.subviews) {
//        if (i == 0)
//            continue;
//        float centerY = self.bounds.size.height / 2.0f;
//        CGPoint center = view.center;
//        center.y = centerY;
//        view.center = center;
//    }
//}
//@end

@interface HomeTabViewController ()
- (void)gotoSearch;//搜索文章
@end

@implementation HomeTabViewController
@synthesize filterView,hotViewController,newsViewController,videoViewController,dataViewController,bbsViewController,officialWebView,bbsSideMenu,officialSideMenu;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id)initWithTitle:(NSString *)title
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Initialization code
        self.title = title;
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 22, 22);
        [leftButton setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
        [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setShowsTouchWhenHighlighted:YES];
        [leftButton addTarget:self action:@selector(gotoSearch) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *temporaryLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        temporaryLeftBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.rightBarButtonItem = temporaryLeftBarButtonItem;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0, 44, [Globle shareInstance].globleWidth, [Globle shareInstance].globleHeight-44);
	// Do any additional setup after loading the view.
//    filterView = [[DMFilterView alloc] initWithStrings:@[@"攻略", @"数据库", @"资讯", @"论坛"] containerView:self.view];
//    [self.filterView attachToContainerView];
//    [self.filterView setDelegate:self];
//    
//    [self.filterView setSelectedItemBackgroundImage:[UIImage imageNamed:@"tb-selected.png"]];
//    [self.filterView setBackgroundImage:[UIImage imageNamed:@"tabbarbg.png"]];
//
//    [self.filterView setTitlesColor:[UIColor whiteColor]];
//    [self.filterView setTitlesFont:[UIFont fontWithName:@"FZHuangCao-S09S" size:20.0]];//[UIFont systemFontOfSize:16]];
//    [self.filterView setTitleInsets:UIEdgeInsetsMake(7, 0, 0, 0)];
//    [self.filterView setDraggable:YES];
    //[self.filterView hide:NO animated:YES animationCompletion:^{ }];
    
    
    //第一页,资讯
    newsViewController = [[HomeViewController alloc] initWithTitle:@"资讯" withSeg:@[@"热门推荐", @"刀塔小说", @"公告活动"] withCate:@[@"hot", @"novel", @"gong-gao"] withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-40)];
    [self addChildViewController:newsViewController];
    //[hotViewController.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    [self.view addSubview:newsViewController.view];
    [newsViewController.view setHidden:NO];
    
    //第二页,攻略
    //hotViewController = [[HomeViewController alloc] initWithTitle:@"攻略" withUrl:@"re-men-wen-zhang" withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    hotViewController = [[HomeViewController alloc] initWithTitle:@"攻略" withSeg:@[@"新手指导", @"进阶技巧", @"英雄专题"] withCate:@[@"xin-shou-zhi-dao", @"jin-jie-ji-qiao", @"ying-xiong-zhuan-ti"] withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-40-44)];
    [self addChildViewController:hotViewController];
    //[hotViewController.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    [self.view addSubview:hotViewController.view];
    [hotViewController.view setHidden:YES];
    
    
    //第三页,数据库
    dataViewController = [[HorizonViewController alloc] initWithTitle:@"图鉴"];
    [self addChildViewController:dataViewController];
    [dataViewController.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-40)];
    [self.view addSubview:dataViewController.view];
    [self.dataViewController.view setHidden:YES];
    

    //第四页,竞技场 视频
    videoViewController = [[HomeViewController alloc] initWithTitle:@"竞技场" withSeg:@[@"阵容搭配", @"副本攻略", @"竞技场透析"] withCate:@[@"zhen-rong-da-pei", @"fu-ben-gong-lue", @"jing-ji-chang-tou-xi"] withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-40-44)];
    [self addChildViewController:videoViewController];
    [self.view addSubview:videoViewController.view];
    [videoViewController.view setHidden:YES];
    
//    videoViewController = [[VideoViewController alloc] initWithTitle:@"精彩视频" withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
//    //videoViewController = [[HomeViewController alloc] initWithTitle:@"竞技场视频" withSeg:@[@"新手入门", @"进阶技巧", @"副本攻略"] withCate:@[@"xin-shou-gong-lue", @"master", @"fu-ben-gong-lue"] withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-40-44)];
//    [self addChildViewController:videoViewController];
//    //[hotViewController.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
//    [self.view addSubview:videoViewController.view];
//    [videoViewController.view setHidden:YES];
    
    
    
    
    
    //第五页,论坛
    bbsViewController = [[SVWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://bbs.appgame.com/forum-141-1.html"]];
    NSLog(@"init url:%@",bbsViewController.mainWebView.request.URL.absoluteString);
    [self addChildViewController:bbsViewController];
    [bbsViewController.view setFrame:CGRectMake(0, -44, 320, [Globle shareInstance].globleHeight-44)];
    [self.view addSubview:bbsViewController.view];
    [bbsViewController.view setHidden:YES];
    //添加刷新与后退按钮
    UIView *twitterItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [twitterItem setMenuActionWithBlock:^{
        [[bbsViewController mainWebView] goBack];
    }];
    UIImageView *twitterIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [twitterIcon setImage:[UIImage imageNamed:@"Retreat"]];
    [twitterItem addSubview:twitterIcon];
    
    UIView *emailItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [emailItem setMenuActionWithBlock:^{
        [[bbsViewController mainWebView] goForward];
    }];
    UIImageView *emailIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [emailIcon setImage:[UIImage imageNamed:@"Advance"]];
    [emailItem addSubview:emailIcon];
    
    
    UIView *browserItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [browserItem setMenuActionWithBlock:^{
        NSLog(@"reload url:%@",bbsViewController.mainWebView.request.URL.absoluteString);
        [[bbsViewController mainWebView] reload];
    }];
    UIImageView *browserIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [browserIcon setImage:[UIImage imageNamed:@"Refresh"]];
    [browserItem addSubview:browserIcon];
    
    bbsSideMenu = [[HMSideMenu alloc] initWithItems:@[twitterItem, emailItem, browserItem]];
    [bbsSideMenu setItemSpacing:5.0f];
    [[bbsViewController mainWebView] addSubview:bbsSideMenu];
    [bbsSideMenu open];
    
    //添加点击手势
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                 action:@selector(toggleMenu)];
//    tapGesture.delegate = self;
//    tapGesture.cancelsTouchesInView = NO;
//    [self.view addGestureRecognizer:tapGesture];
    
    
    //添加自定义tabbar条
    JMTabView * tabView = [[JMTabView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44., [Globle shareInstance].globleWidth, 44.)];
    tabView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [tabView setDelegate:self];
    
    //UIImage * standardIcon = [UIImage imageNamed:@"icon3.png"];
    //UIImage * highlightedIcon = [UIImage imageNamed:@"icon2.png"];
    
    CustomTabItem * tabItem1 = [CustomTabItem tabItemWithTitle:@"资讯" icon:[UIImage imageNamed:@"tb-icon-one.png"] alternateIcon:[UIImage imageNamed:@"tb-icon-one.png"]];
    CustomTabItem * tabItem2 = [CustomTabItem tabItemWithTitle:@"攻略" icon:[UIImage imageNamed:@"tb-icon-two.png"] alternateIcon:[UIImage imageNamed:@"tb-icon-two.png"]];
    CustomTabItem * tabItem3 = [CustomTabItem tabItemWithTitle:@"图鉴" icon:[UIImage imageNamed:@"tb-icon-three.png"] alternateIcon:[UIImage imageNamed:@"tb-icon-three.png"]];
    CustomTabItem * tabItem4 = [CustomTabItem tabItemWithTitle:@"竞技场" icon:[UIImage imageNamed:@"tb-icon-four.png"] alternateIcon:[UIImage imageNamed:@"tb-icon-four.png"]];
    CustomTabItem * tabItem5 = [CustomTabItem tabItemWithTitle:@"论坛" icon:[UIImage imageNamed:@"tb-icon-five.png"] alternateIcon:[UIImage imageNamed:@"tb-icon-five.png"]];
    
    [tabView addTabItem:tabItem1];
    [tabView addTabItem:tabItem2];
    [tabView addTabItem:tabItem3];
    [tabView addTabItem:tabItem4];
    [tabView addTabItem:tabItem5];
    
    [tabView setSelectionView:[CustomSelectionView createSelectionView]];
    [tabView setItemSpacing:1.];
    [tabView setBackgroundLayer:[[CustomBackgroundLayer alloc] init]];
    
    //    You can run blocks by specifiying an executeBlock: paremeter
    //    #if NS_BLOCKS_AVAILABLE
    //    [tabView addTabItemWithTitle:@"One" icon:nil executeBlock:^{NSLog(@"abc");}];
    //    #endif
    
    [tabView setSelectedIndex:0];
    [self.view addSubview:tabView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //[self.navigationController.navigationBar setTranslucent:NO];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        //IOS5
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top.png"] forBarMetrics:UIBarMetricsDefault];
        //self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
        //self.navigationController.navigationBar.tintColor = [UIColor clearColor];
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor] ,UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0], UITextAttributeFont,nil];
    }
}

- (BOOL) automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return YES;
}

- (BOOL) shouldAutomaticallyForwardRotationMethods {
    return YES;
}

- (BOOL) shouldAutomaticallyForwardAppearanceMethods {
    return YES;
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

#pragma mark - Class Methods
- (void)gotoSearch{
    //设置搜索页出现
    //[self.RootScrollView setContentOffset:CGPointMake(6*320, 0) animated:YES];
    SearchViewController *searchController = [[SearchViewController alloc] initWithTitle:@"搜索" withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight)];
    
    [self.navigationController pushViewController:searchController animated:YES];
}

//#pragma mark - ScrollView delegate
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    //[self.filterView hide:YES animated:YES animationCompletion:^{}];
//    [self.bbsSideMenu close];
//    [self.officialSideMenu close];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    //[self.filterView hide:NO animated:YES animationCompletion:^{}];
//    [self.bbsSideMenu open];
//    [self.officialSideMenu open];
//
//}

- (void)toggleMenu {
    if (self.bbsSideMenu.isOpen)
        [self.bbsSideMenu close];
    else
        [self.bbsSideMenu open];    
}

#pragma mark - FilterVie delegate
- (void)filterView:(DMFilterView *)filterView didSelectedAtIndex:(NSInteger)index
{
    NSLog(@"%d", index);
    switch (index) {
        case 0:
            newsViewController.view.hidden = NO;
            hotViewController.view.hidden = YES;
            dataViewController.view.hidden = YES;
            videoViewController.view.hidden = YES;
            bbsViewController.view.hidden = YES;
            break;
        
        case 1:
            newsViewController.view.hidden = YES;
            hotViewController.view.hidden = NO;
            dataViewController.view.hidden = YES;
            videoViewController.view.hidden = YES;
            bbsViewController.view.hidden = YES;
            break;

        case 2:
            newsViewController.view.hidden = YES;
            hotViewController.view.hidden = YES;
            dataViewController.view.hidden = NO;
            videoViewController.view.hidden = YES;
            bbsViewController.view.hidden = YES;
            break;

        case 3:
            newsViewController.view.hidden = YES;
            hotViewController.view.hidden = YES;
            dataViewController.view.hidden = YES;
            videoViewController.view.hidden = NO;
            bbsViewController.view.hidden = YES;
            break;
            
        case 4:
            newsViewController.view.hidden = YES;
            hotViewController.view.hidden = YES;
            dataViewController.view.hidden = YES;
            videoViewController.view.hidden = YES;
            bbsViewController.view.hidden = NO;
            break;
            
        default:
            break;
    }
}

- (CGFloat )filterViewSelectionAnimationSpeed:(DMFilterView *)filterView
{
    //return the default value as example, you don't have to implement this delegate
    //if you don't want to modify the selection speed
    //Or you can return 0.0 to disable the animation totally
    return kAnimationSpeed;
}

-(void)tabView:(JMTabView *)tabView didSelectTabAtIndex:(NSUInteger)itemIndex;
{
    NSLog(@"Selected Tab Index: %d", itemIndex);
    switch (itemIndex) {
        case 0:
            newsViewController.view.hidden = NO;
            hotViewController.view.hidden = YES;
            dataViewController.view.hidden = YES;
            videoViewController.view.hidden = YES;
            bbsViewController.view.hidden = YES;
            break;
            
        case 1:
            newsViewController.view.hidden = YES;
            hotViewController.view.hidden = NO;
            dataViewController.view.hidden = YES;
            videoViewController.view.hidden = YES;
            bbsViewController.view.hidden = YES;
            break;
            
        case 2:
            newsViewController.view.hidden = YES;
            hotViewController.view.hidden = YES;
            dataViewController.view.hidden = NO;
            videoViewController.view.hidden = YES;
            bbsViewController.view.hidden = YES;
            break;
            
        case 3:
            newsViewController.view.hidden = YES;
            hotViewController.view.hidden = YES;
            dataViewController.view.hidden = YES;
            videoViewController.view.hidden = NO;
            bbsViewController.view.hidden = YES;
            break;
            
        case 4:
            newsViewController.view.hidden = YES;
            hotViewController.view.hidden = YES;
            dataViewController.view.hidden = YES;
            videoViewController.view.hidden = YES;
            bbsViewController.view.hidden = NO;
            break;
            
        default:
            break;
    }
}

@end

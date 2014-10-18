//
//  HomeTabViewController.m
//  RaidersSD
//
//  Created by 计 炜 on 13-8-28.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "HomeTabViewController.h"

#import "SVWebViewController.h"
#import "segWebViewController.h"
#import "HMSideMenu.h"
#import "SearchViewController.h"
#import "NewsViewController.h"
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
- (void)gotoNews;//打开主站资讯文章
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
        [leftButton setBackgroundImage:[UIImage imageNamed:@"article.png"] forState:UIControlStateNormal];
        [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setShowsTouchWhenHighlighted:YES];
        [leftButton addTarget:self action:@selector(gotoNews) forControlEvents:UIControlEventTouchUpInside];

        //[leftButton setTitle:@"更多资讯" forState:UIControlStateNormal];
        //[leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UIBarButtonItem *temporaryLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        temporaryLeftBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.leftBarButtonItem = temporaryLeftBarButtonItem;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 22, 22);
        [rightButton setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
        [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [rightButton setShowsTouchWhenHighlighted:YES];
        [rightButton addTarget:self action:@selector(gotoSearch) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *temporaryRightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        temporaryRightBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.rightBarButtonItem = temporaryRightBarButtonItem;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0, 44, [Globle shareInstance].globleWidth, [Globle shareInstance].globleHeight-44);

    NSDictionary *dictionary;
    NSString *bbsUrlStr = @"http://bbs.appgame.com/forum-141-1.html";
    
//    AVObject *vcKeyObject = [AVObject objectWithClassName:@"VcKeyObject"];
//    [vcKeyObject setObject:dictionary forKey:@"VcKeyDictionary"];
//    [vcKeyObject save];
    AVQuery *query = [AVQuery queryWithClassName:@"VcKeyObject_v1_1"];//不同版本,配置表不同,这个表示v1.1
    AVObject *VcKeyObject = [query getFirstObject];
    if(!VcKeyObject){
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"热门推荐", @"title11",
                      @"hot", @"cate11",
                      @"刀塔小说", @"title12",
                      @"novel",  @"cate12",
                      @"新闻公告", @"title13",
                      @"gong-gao",  @"cate13",
                      
                      @"新手指导", @"title21",
                      @"newer", @"cate21",
                      @"进阶技巧", @"title22",
                      @"gong-lue", @"cate22",
                      @"英雄专题", @"title23",
                      @"xin-de", @"cate23",
                      
                      @"阵容搭配", @"title31",
                      @"zr-dp", @"cate31",
                      @"副本攻略", @"title32",
                      @"fu-ben-gl", @"cate32",
                      @"竞技视频", @"title33",
                      @"pk-video", @"cate33",
                      
                      @"论坛", @"bbsTitle",
                      @"http://bbs.appgame.com/forum-141-1.html", @"bbsUrl",
                      nil];
    }else {
        dictionary = [VcKeyObject objectForKey:@"VcKeyDictionary"];
        bbsUrlStr = [VcKeyObject objectForKey:@"BbsUrlStr"];
    }

//    {"title22":"进阶技巧","title21":"新手指导","cate11":"hot","title13":"公告活动","title12":"刀塔小说","title11":"热门推荐","title31":"阵容搭配","title32":"副本攻略","bbsUrl":"http://bbs.appgame.com/forum-141-1.html","cate13":"gong-gao","cate12":"novel","bbsTitle":"论坛","cate31":"zr-dp","cate32":"fu-ben-gl","cate33":"pk-video","cate23":"xin-de","title33":"竞技场透析","cate21":"newer","cate22":"gong-lue","title23":"英雄专题"}
    
    
    //第一页,资讯
    newsViewController = [[HomeViewController alloc] initWithTitle:@"资讯" withSeg:@[[dictionary objectForKey:@"title11"] , [dictionary objectForKey:@"title12"], [dictionary objectForKey:@"title13"]] withCate:@[[dictionary objectForKey:@"cate11"], [dictionary objectForKey:@"cate12"], [dictionary objectForKey:@"cate13"]] withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    [self addChildViewController:newsViewController];
    //[hotViewController.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    [self.view addSubview:newsViewController.view];
    [newsViewController.view setHidden:NO];
    
    //第二页,攻略
    //hotViewController = [[HomeViewController alloc] initWithTitle:@"攻略" withUrl:@"re-men-wen-zhang" withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    hotViewController = [[HomeViewController alloc] initWithTitle:@"攻略" withSeg:@[[dictionary objectForKey:@"title21"], [dictionary objectForKey:@"title22"], [dictionary objectForKey:@"title23"]] withCate:@[[dictionary objectForKey:@"cate21"], [dictionary objectForKey:@"cate22"], [dictionary objectForKey:@"cate23"]] withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    [self addChildViewController:hotViewController];
    //[hotViewController.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    [self.view addSubview:hotViewController.view];
    [hotViewController.view setHidden:YES];
    
    
    //第三页,数据库
    //dataViewController = [[HorizonViewController alloc] initWithTitle:@"图鉴"];
    dataViewController = [[DataViewController alloc] init];
    [self addChildViewController:dataViewController];
    [dataViewController.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    [self.view addSubview:dataViewController.view];
    [self.dataViewController.view setHidden:YES];
    

    //第四页,竞技场 视频
    videoViewController = [[HomeViewController alloc] initWithTitle:@"竞技场" withSeg:@[[dictionary objectForKey:@"title31"], [dictionary objectForKey:@"title32"], [dictionary objectForKey:@"title33"]] withCate:@[[dictionary objectForKey:@"cate31"], [dictionary objectForKey:@"cate32"], [dictionary objectForKey:@"cate33"]] withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    [self addChildViewController:videoViewController];
    [self.view addSubview:videoViewController.view];
    [videoViewController.view setHidden:YES];
    

    //第五页,论坛
    //bbsViewController = [[SVWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://bbs.appgame.com/forum-141-1.html"]];
    bbsViewController = [[GHRootViewController alloc] initWithTitle:[dictionary objectForKey:@"bbsTitle"] withUrl:bbsUrlStr];
    //NSLog(@"init url:%@",bbsViewController.mainWebView.request.URL.absoluteString);
    [self addChildViewController:bbsViewController];
    [bbsViewController.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
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
        NSLog(@"reload url:%@,weburl:%@",bbsViewController.mainWebView.request.URL.absoluteString,self.bbsViewController.webURL);
        [bbsViewController reloadClicked];
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
    //[self.bbsViewController.mainWebView loadRequest:[NSURLRequest requestWithURL:self.bbsViewController.webURL]];
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

- (void)gotoNews{
    //设置搜索页出现
    //[self.RootScrollView setContentOffset:CGPointMake(6*320, 0) animated:YES];
    NewsViewController *vc = [[NewsViewController alloc] initWithNibName:@"NewsViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}


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

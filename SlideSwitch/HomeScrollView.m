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

#define POSITIONID (int)scrollView.contentOffset.x/320

//按钮空隙
#define BUTTONGAP 10
//按钮长度
#define BUTTONWIDTH 59
//按钮宽度
#define BUTTONHEIGHT 30
//滑条CONTENTSIZEX
#define CONTENTSIZEX 220

#define BUTTONID (sender.tag-100)

static CGFloat ImageHeight  = 150.0;
static CGFloat ImageWidth  = 320.0;

@interface HomeScrollView ()
- (void)revealSidebar;
- (void)getComments;

- (void)goHomeView:(UIButton *)sender;

@property (nonatomic, strong) UIWebView *bbsWebView;
@property (nonatomic, assign) BOOL menuIsVisible;
@property (nonatomic, strong) HMSideMenu *sideMenu;
@end

@implementation HomeScrollView

@synthesize viewNameArray;
@synthesize nameArray;
@synthesize scrollViewSelectedChannelID;
@synthesize RootScrollView,TopScrollView,bgImage,bbsWebView;
@synthesize comments,pullToRefreshTableView,webURL,nextCursor;

#pragma mark - Class Methods
- (void)revealSidebar {
	_revealBlock();
}

- (void)goHomeView:(UIButton *)sender{
    UIButton *btn = sender;
    NSString *title;
    NSString *url;
    if(btn.tag == 2001)
    {url = @"news"; title = @"最新资讯";}
    else if(btn.tag == 2002)
    {url = @"newer"; title = @"基础指引";}
    else if(btn.tag == 2003)
    {url = @"fubenziliao"; title = @"副本通关";}
    else if(btn.tag == 2004)
    {url = @"equipment"; title = @"合成掉落";}
    else if(btn.tag == 2005)
    {url = @"jing-cai-shi-pin"; title = @"精彩视频";}
    else if(btn.tag == 2006)
    {url = @"re-men-wen-zhang"; title = @"英雄装备";}
    else if(btn.tag == 2007)
    {url = @"ka-pai-zhuan-ti-2"; title = @"英雄专题";}
    else if(btn.tag == 2008)
    {url = @"chengzhangzhilu"; title = @"成长进阶";}
    
    HomeViewController *homeViewController = [[HomeViewController alloc] initWithTitle:title withUrl:url];
    [self.navigationController pushViewController:homeViewController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];
    self.RootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    self.RootScrollView.backgroundColor = [UIColor clearColor];
    self.viewNameArray = [NSArray arrayWithObjects:@"攻略", @"常见", @"论坛", nil];
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
    
    
    self.TopScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(50, [Globle shareInstance].globleHeight-44-44, CONTENTSIZEX, 44)];
    self.TopScrollView.backgroundColor = [UIColor clearColor];
    self.TopScrollView.pagingEnabled = NO;
    self.TopScrollView.showsHorizontalScrollIndicator = NO;
    self.TopScrollView.showsVerticalScrollIndicator = NO;
    self.nameArray = [NSArray arrayWithObjects:@"攻略", @"常见", @"论坛", nil];
    self.TopScrollView.contentSize = CGSizeMake((BUTTONWIDTH+BUTTONGAP)*[self.nameArray count]+BUTTONGAP, 44);
    
    userSelectedChannelID = 100;
    scrollViewSelectedChannelID = 100;
    //self.TopScrollView.delegate = self;
    self.TopScrollView.tag = 1002;
    [self initWithNameButtons];
    [self.view addSubview:self.TopScrollView];
    
    // get array of articles
    [self getComments];
}

- (void)viewWillAppear:(BOOL)animated {
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTranslucent:NO];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        //IOS5
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top.png"] forBarMetrics:UIBarMetricsDefault];
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

- (id)initWithTitle:(NSString *)title withRevealBlock:(ScrollRevealBlock)revealBlock
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Initialization code        
        self.title = title;
        _revealBlock = [revealBlock copy];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 41, 28);
        [leftButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setShowsTouchWhenHighlighted:YES];
        [leftButton addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *temporaryLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        temporaryLeftBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.leftBarButtonItem = temporaryLeftBarButtonItem;
    }
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:singleTap];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    }
    alerViewManager = [[AlerViewManager alloc] init];
    ifNeedFristLoading = YES;
    
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
    //设置第一页
//    UIImage *image = [UIImage imageNamed:@"bg.png"];
//    self.imgProfile = [[UIImageView alloc] initWithImage:image];
//    self.imgProfile.frame             = CGRectMake(0, 0, ImageWidth, ImageHeight);
//    [self.view addSubview:self.imgProfile];
    bgImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ImageWidth, ImageHeight)];
    [bgImage setImage: [UIImage imageNamed:@"ZGAppGame.png"]];
    [self.RootScrollView addSubview:bgImage];
    
    UIButton *newsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    newsButton.frame = CGRectMake(15, ImageHeight+10, 50, 66);
    [newsButton setBackgroundImage:[UIImage imageNamed:@"ka-1.png"] forState:UIControlStateNormal];
    [newsButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [newsButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [newsButton setShowsTouchWhenHighlighted:YES];
    [newsButton addTarget:self action:@selector(goHomeView:) forControlEvents:UIControlEventTouchUpInside];
    newsButton.tag = 2001;
    [self.RootScrollView addSubview:newsButton];
    UILabel *newsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, ImageHeight+10+66, 50, 15)];
    newsLabel.text = @"最新资讯";
    newsLabel.textColor = [UIColor yellowColor];
    [newsLabel setFont:[UIFont fontWithName:@"DFPHaiBaoW12" size:12.0]];
    newsLabel.backgroundColor = [UIColor clearColor];
    [self.RootScrollView addSubview:newsLabel];
        
    UIButton *basicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    basicButton.frame = CGRectMake(15+80, ImageHeight+10, 50, 66);
    [basicButton setBackgroundImage:[UIImage imageNamed:@"ka-2.png"] forState:UIControlStateNormal];
    [basicButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [basicButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [basicButton setShowsTouchWhenHighlighted:YES];
    [basicButton addTarget:self action:@selector(goHomeView:) forControlEvents:UIControlEventTouchUpInside];
    basicButton.tag = 2002;
    [self.RootScrollView addSubview:basicButton];
    UILabel *basicLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+80, ImageHeight+10+66, 50, 15)];
    basicLabel.text = @"基础指引";
    basicLabel.textColor = [UIColor yellowColor];
    [basicLabel setFont:[UIFont fontWithName:@"DFPHaiBaoW12" size:12.0]];
    basicLabel.backgroundColor = [UIColor clearColor];
    [self.RootScrollView addSubview:basicLabel];
        
    UIButton *fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fbButton.frame = CGRectMake(15+80*2, ImageHeight+10, 50, 66);
    [fbButton setBackgroundImage:[UIImage imageNamed:@"ka-3.png"] forState:UIControlStateNormal];
    [fbButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [fbButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [fbButton setShowsTouchWhenHighlighted:YES];
    [fbButton addTarget:self action:@selector(goHomeView:) forControlEvents:UIControlEventTouchUpInside];
    fbButton.tag = 2003;
    [self.RootScrollView addSubview:fbButton];
    UILabel *fbLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+80*2, ImageHeight+10+66, 50, 15)];
    fbLabel.text = @"副本通关";
    fbLabel.textColor = [UIColor yellowColor];
    [fbLabel setFont:[UIFont fontWithName:@"DFPHaiBaoW12" size:12.0]];
    fbLabel.backgroundColor = [UIColor clearColor];
    [self.RootScrollView addSubview:fbLabel];
    
    UIButton *dropButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dropButton.frame = CGRectMake(15+80*3, ImageHeight+10, 50, 66);
    [dropButton setBackgroundImage:[UIImage imageNamed:@"ka-4.png"] forState:UIControlStateNormal];
    [dropButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [dropButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [dropButton setShowsTouchWhenHighlighted:YES];
    [dropButton addTarget:self action:@selector(goHomeView:) forControlEvents:UIControlEventTouchUpInside];
    dropButton.tag = 2004;
    [self.RootScrollView addSubview:dropButton];
    UILabel *dropLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+80*3, ImageHeight+10+66, 50, 15)];
    dropLabel.text = @"合成掉落";
    dropLabel.textColor = [UIColor yellowColor];
    [dropLabel setFont:[UIFont fontWithName:@"DFPHaiBaoW12" size:12.0]];
    dropLabel.backgroundColor = [UIColor clearColor];
    [self.RootScrollView addSubview:dropLabel];
        
    UIButton *vedioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    vedioButton.frame = CGRectMake(15, ImageHeight+10+100, 50, 66);
    [vedioButton setBackgroundImage:[UIImage imageNamed:@"ka-5.png"] forState:UIControlStateNormal];
    [vedioButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [vedioButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [vedioButton setShowsTouchWhenHighlighted:YES];
    [vedioButton addTarget:self action:@selector(goHomeView:) forControlEvents:UIControlEventTouchUpInside];
    vedioButton.tag = 2005;
    [self.RootScrollView addSubview:vedioButton];
    UILabel *vedioLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, ImageHeight+110+66, 50, 15)];
    vedioLabel.text = @"精彩视频";
    vedioLabel.textColor = [UIColor yellowColor];
    [vedioLabel setFont:[UIFont fontWithName:@"DFPHaiBaoW12" size:12.0]];
    vedioLabel.backgroundColor = [UIColor clearColor];
    [self.RootScrollView addSubview:vedioLabel];
        
    UIButton *equipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    equipButton.frame = CGRectMake(15+80, ImageHeight+10+100, 50, 66);
    [equipButton setBackgroundImage:[UIImage imageNamed:@"ka-6.png"] forState:UIControlStateNormal];
    [equipButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [equipButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [equipButton setShowsTouchWhenHighlighted:YES];
    [equipButton addTarget:self action:@selector(goHomeView:) forControlEvents:UIControlEventTouchUpInside];
    equipButton.tag = 2006;
    [self.RootScrollView addSubview:equipButton];
    UILabel *equipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+80, ImageHeight+110+66, 50, 15)];
    equipLabel.text = @"英雄装备";
    equipLabel.textColor = [UIColor yellowColor];
    [equipLabel setFont:[UIFont fontWithName:@"DFPHaiBaoW12" size:12.0]];
    equipLabel.backgroundColor = [UIColor clearColor];
    [self.RootScrollView addSubview:equipLabel];
        
    UIButton *heroButton = [UIButton buttonWithType:UIButtonTypeCustom];
    heroButton.frame = CGRectMake(15+80*2, ImageHeight+10+100, 50, 66);
    [heroButton setBackgroundImage:[UIImage imageNamed:@"ka-7.png"] forState:UIControlStateNormal];
    [heroButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [heroButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [heroButton setShowsTouchWhenHighlighted:YES];
    [heroButton addTarget:self action:@selector(goHomeView:) forControlEvents:UIControlEventTouchUpInside];
    heroButton.tag = 2007;
    [self.RootScrollView addSubview:heroButton];
    UILabel *heroLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+80*2, ImageHeight+110+66, 50, 15)];
    heroLabel.text = @"英雄专题";
    heroLabel.textColor = [UIColor yellowColor];
    [heroLabel setFont:[UIFont fontWithName:@"DFPHaiBaoW12" size:12.0]];
    heroLabel.backgroundColor = [UIColor clearColor];
    [self.RootScrollView addSubview:heroLabel];
        
    UIButton *advanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    advanceButton.frame = CGRectMake(15+80*3, ImageHeight+10+100, 50, 66);
    [advanceButton setBackgroundImage:[UIImage imageNamed:@"ka-8.png"] forState:UIControlStateNormal];
    [advanceButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [advanceButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [advanceButton setShowsTouchWhenHighlighted:YES];
    [advanceButton addTarget:self action:@selector(goHomeView:) forControlEvents:UIControlEventTouchUpInside];
    advanceButton.tag = 2008;
    [self.RootScrollView addSubview:advanceButton];
    UILabel *advanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+80*3, ImageHeight+110+66, 50, 15)];
    advanceLabel.text = @"成长进阶";
    advanceLabel.textColor = [UIColor yellowColor];
    [advanceLabel setFont:[UIFont fontWithName:@"DFPHaiBaoW12" size:12.0]];
    advanceLabel.backgroundColor = [UIColor clearColor];
    [self.RootScrollView addSubview:advanceLabel];
    
    //增加两横三竖分割线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, ImageHeight+100, [UIScreen mainScreen].bounds.size.width, 1.0f)];
    topLine.backgroundColor = [UIColor colorWithRed:(18.0f/255.0f) green:(53.0f/255.0f) blue:(80.0f/255.0f) alpha:1.0f];
    [self.RootScrollView addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, ImageHeight+200, [UIScreen mainScreen].bounds.size.width, 1.0f)];
    bottomLine.backgroundColor = [UIColor colorWithRed:(18.0f/255.0f) green:(53.0f/255.0f) blue:(80.0f/255.0f) alpha:1.0f];
    [self.RootScrollView addSubview:bottomLine];
    
    UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(80.0f, ImageHeight, 1.0f, 200.0f)];
    leftLine.backgroundColor = [UIColor colorWithRed:(18.0f/255.0f) green:(53.0f/255.0f) blue:(80.0f/255.0f) alpha:1.0f];
    [self.RootScrollView addSubview:leftLine];
    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(80.0f*2, ImageHeight, 1.0f, 200.0f)];
    midLine.backgroundColor = [UIColor colorWithRed:(18.0f/255.0f) green:(53.0f/255.0f) blue:(80.0f/255.0f) alpha:1.0f];
    [self.RootScrollView addSubview:midLine];

    
    UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(80.0f*3, ImageHeight, 1.0f, 200.0f)];
    rightLine.backgroundColor = [UIColor colorWithRed:(18.0f/255.0f) green:(53.0f/255.0f) blue:(80.0f/255.0f) alpha:1.0f];
    [self.RootScrollView addSubview:rightLine];

    
    //设置第二页
    comments = [[NSMutableArray alloc] init];
    start = 0;
    receiveMember = 0;
    
    pullToRefreshTableView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(320, 0, 320, [Globle shareInstance].globleHeight-44-44) withType: withStateViews];
    
    //[self.pullToRefreshTableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    pullToRefreshTableView.delegate = self;
    pullToRefreshTableView.dataSource = self;
    pullToRefreshTableView.allowsSelection = YES;
    pullToRefreshTableView.backgroundColor = [UIColor clearColor];
    //pullToRefreshTableView.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:244.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
    pullToRefreshTableView.backgroundColor = [UIColor colorWithRed:19.0f/255 green:47.0f/255 blue:69.0f/255 alpha:1.0];
    pullToRefreshTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    pullToRefreshTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [pullToRefreshTableView setHidden:NO];
    [self.RootScrollView addSubview:pullToRefreshTableView];
    

    //设置第三页
    bbsWebView = [[UIWebView alloc] initWithFrame:CGRectMake(320*2, -44, 320, [Globle shareInstance].globleHeight-44)];
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
}

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
        
    }else if (scrollView.tag == 1002){        
    }else{
        [pullToRefreshTableView tableViewDidDragging];
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.tag != 1001 && scrollView.tag != 1002) {
        NSInteger returnKey = [pullToRefreshTableView tableViewDidEndDragging];
        
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)initWithNameButtons
{
    shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 59, 44)];
    [shadowImageView setImage:[UIImage imageNamed:@"yellow_line_and_shadow.png"]];
    [self.TopScrollView addSubview:shadowImageView];
    
    for (int i = 0; i < [self.nameArray count]; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(BUTTONGAP+(BUTTONGAP+BUTTONWIDTH)*i, 9, BUTTONWIDTH, 30)];
        [button setTag:i+100];
        if (i == 0) {
            button.selected = YES;
        }
        [button setTitle:[NSString stringWithFormat:@"%@",[self.nameArray objectAtIndex:i]] forState:UIControlStateNormal];
        //button.titleLabel.font = [UIFont systemFontOfSize:20.0];
        button.titleLabel.font = [UIFont fontWithName:@"DFPHaiBaoW12" size:20.0];
        
        //[button setTitleColor:[Globle colorFromHexRGB:@"868686"] forState:UIControlStateNormal];
        //[button setTitleColor:[Globle colorFromHexRGB:@"bb0b15"] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectNameButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.TopScrollView addSubview:button];
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
        //赋值按钮ID
        userSelectedChannelID = sender.tag;
    }
    
    //按钮选中状态
    if (!sender.selected) {
        sender.selected = YES;
        
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
}

- (void)setButtonSelect
{
    //滑动选中按钮
    UIButton *button = (UIButton *)[self.TopScrollView viewWithTag:scrollViewSelectedChannelID];
    
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

#pragma mark -
#pragma mark - UITableViewDelegate

//某一行被选中,由ViewController来实现push详细页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailViewController *viewController = [[DetailViewController alloc] initWithTitle:@"常见"];
    viewController.appData = self.comments;
    viewController.startIndex = indexPath.row;

    //NSLog(@"didSelectArticle:%@",aArticle.content);
    [self.navigationController pushViewController:viewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//反选
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //return 60.0f;
    
    ArticleItem *comment = (ArticleItem *)[self.comments objectAtIndex:indexPath.row];
    CGSize constraint = CGSizeMake(320.0f-16.0, 20000);
    CGSize size = [comment.title sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:16] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    return MAX(size.height, 20.0f) + 40.0f;//计算每一个cell的高度
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([comments count] == 0) {
        //  本方法是为了在数据为空时，让“下拉刷新”视图可直接显示，比较直观
        tableView.contentInset = UIEdgeInsetsMake(k_STATE_VIEW_HEIGHT, 0, 0, 0);
    }
    return [comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    ArticleItemCell *cell = (ArticleItemCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ArticleItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // Leave cells empty if there's no data yet
    int nodeCount = [self.comments count];
    
    if (nodeCount > 0)
	{
        // Set up the cell...
        ArticleItem *aComment = [self.comments objectAtIndex:indexPath.row];
        cell.descriptLabel.text = aComment.description;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        cell.dateLabel.text = [dateFormatter stringFromDate:aComment.pubDate];
        
        cell.creatorLabel.text = aComment.creator;
        //        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000);
        //        CGSize size = [aArticle.description sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        cell.articleLabel.text = aComment.title;
        //        cell.articleLabel.frame = CGRectMake(4.0, 52.0,
        //                                             CELL_CONTENT_WIDTH - (2 * CELL_CONTENT_MARGIN),
        //                                             45.0 + CELL_CONTENT_MARGIN);
        
        // Only load cached images; defer new downloads until scrolling ends
        //当tableview停下来的时候才下载缩略图
        //if (pullToRefreshTableView.dragging == NO && pullToRefreshTableView.decelerating == NO)
        //[cell.imageView setImageWithURL:[NSURL URLWithString:aComment.authorAvatar]
         //              placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
        
        CGSize constraint = CGSizeMake(320.0f-16.0, 20000);
        CGSize size = [cell.articleLabel.text sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:16] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        [cell.articleLabel setFrame:CGRectMake(8.0, 20.0, 320.0-16.0, MAX(size.height, 20.0f))];
        
    }
    
    return cell;
}

#pragma mark -
#pragma mark - Table View control

- (void)updateThread:(NSString *)returnKey{
    @autoreleasepool {
        sleep(2);
        switch ([returnKey intValue]) {
            case k_RETURN_REFRESH:
            {
                [comments removeAllObjects];
                start = 0;
                self.nextCursor = nil;
                [self performSelectorOnMainThread:@selector(getComments) withObject:nil waitUntilDone:NO];
                break;
            }
            case k_RETURN_LOADMORE:
            {
                start = [self.comments count]/20 + 1;
                
                [self performSelectorOnMainThread:@selector(getComments) withObject:nil waitUntilDone:NO];
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
    if (receiveMember  >= 20)
    //if (hasNext)
    {
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果数据还能继续加载，则传入NO
        [pullToRefreshTableView reloadData:NO];
    }
    else
    {
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果已全部加载，则传入YES
        [pullToRefreshTableView reloadData:YES];
    }
}

- (void)getComments {
    
    [alerViewManager showMessage:@"正在加载数据" inView:self.view];
    self.webURL = @"http://dt.appgame.com/category/faq/";

    NSString *starString =  [NSString stringWithFormat:@"%ld", (long)start];
    AFHTTPClient *jsonapiClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:self.webURL]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"get_posts", @"json",
                                @"20", @"count",
                                starString, @"page",
                                nil];
    [jsonapiClient getPath:@""
                parameters:parameters
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       
                       __block NSString *jsonString = operation.responseString;
                       
                       //过滤掉w3tc缓存附加在json数据后面的
                       /*
                        <!-- W3 Total Cache: Page cache debug info:
                        Engine:             memcached
                        Cache key:          4e14f98a5d7a178df9c7d3251ace098d
                        Caching:            enabled
                        Status:             not cached
                        Creation Time:      2.143s
                        Header info:
                        X-Powered-By:        PHP/5.4.14-1~precise+1
                        X-W3TC-Minify:       On
                        Last-Modified:       Sun, 12 May 2013 16:17:48 GMT
                        Vary:
                        X-Pingback:           http://www.appgame.com/xmlrpc.php
                        Content-Type:         application/json; charset=UTF-8
                        -->
                        */
                       NSError *error;
                       //(.|\\s)*或([\\s\\S]*)可以匹配包括换行在内的任意字符
                       NSRegularExpression *regexW3tc = [NSRegularExpression
                                                         regularExpressionWithPattern:@"<!-- W3 Total Cache:([\\s\\S]*)-->"
                                                         options:NSRegularExpressionCaseInsensitive
                                                         error:&error];
                       [regexW3tc enumerateMatchesInString:jsonString
                                                   options:0
                                                     range:NSMakeRange(0, jsonString.length)
                                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                                    jsonString = [jsonString stringByReplacingOccurrencesOfString:[jsonString substringWithRange:result.range] withString:@""];
                                                }];
                       
                       jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                       
                       NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                       // fetch the json response to a dictionary
                       NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                       // pass it to the block
                       // check the code (success is 0)
                       NSString *code = [responseDictionary objectForKey:@"status"];
                       
                       if (![code isEqualToString:@"ok"]) {   // there's an error
                           NSLog(@"获取文章json异常:%@",self.webURL);
                       }else {
                           receiveMember = [[responseDictionary objectForKey:@"count"] integerValue];
                           if (receiveMember > 0) {                               
                               NSMutableArray *_comments = [NSMutableArray array];
                               // parse into array of comments
                               NSArray *commentsArray = [responseDictionary objectForKey:@"posts"];
                               
                               // setting date format
                               NSDateFormatter *df = [[NSDateFormatter alloc] init];
                               NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                               [df setLocale:locale];
                               [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                               
                               // traverse the array, getting data for comments
                               for (NSDictionary *commentDictionary in commentsArray) {
                                   // for every comment, wrap them with IADisqusComment
                                   ArticleItem *aComment = [[ArticleItem alloc] init];
                                   
                                   //aComment.articleIconURL = [NSURL URLWithString:[[commentDictionary objectForKey:@"thumbnail"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                   aComment.pubDate = [df dateFromString:[[commentDictionary objectForKey:@"date"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                                   
                                   aComment.description = [commentDictionary objectForKey:@"excerpt"];
                                   aComment.title = [commentDictionary objectForKey:@"title_plain"];
                                   aComment.content = [commentDictionary objectForKey:@"content"];
                                   aComment.articleURL = [NSURL URLWithString:[[commentDictionary objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                   aComment.creator = [[commentDictionary objectForKey:@"author"] objectForKey:@"nickname"];
                                   
                                   if (aComment.content != nil) {
                                       NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"appgame" ofType:@"html"];
                                       NSString *htmlString = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
                                       NSString *contentHtml = @"";
                                       NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                       [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
                                       contentHtml = [contentHtml stringByAppendingFormat:htmlString,
                                                      aComment.title, aComment.creator, [dateFormatter stringFromDate:aComment.pubDate]];
                                       contentHtml = [contentHtml stringByReplacingOccurrencesOfString:@"<!--content-->" withString:aComment.content];
                                       aComment.content = contentHtml;
                                   }
                                   // add the comment to the mutable array
                                   [_comments addObject:aComment];
                               }
                               
                               for (ArticleItem *commentItem in _comments) {
                                   [self.comments addObject:commentItem];
                               }
                               //self.comments = [NSMutableArray arrayWithArray:_comments];
                               
                               [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                           }
                           //到这里就是0条数据
                       }
                       [alerViewManager dismissMessageView:self.view];
                       if ([pullToRefreshTableView isHidden])
                       {
                           [pullToRefreshTableView setHidden:NO];
                       }
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       // pass error to the block
                       NSLog(@"获取文章json失败:%@",error);
                       [alerViewManager dismissMessageView:self.view];
                   }];
}

@end

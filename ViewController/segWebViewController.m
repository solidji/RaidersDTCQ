//
//  segWebViewController.m
//  RaidersSD
//
//  Created by 计 炜 on 13-8-31.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "segWebViewController.h"
#import "HMSideMenu.h"
#import "Globle.h"

@interface segWebViewController ()

@property (nonatomic) BOOL web2Loaded,web3Loaded;

- (void)toggleMenu;

@end

@implementation segWebViewController
@synthesize webVC1,webVC2,webVC3,webSideMenu1,webSideMenu2,webSideMenu3;
@synthesize segOneBtn,segTwoBtn,segThreeBtn,segmentedPerson,segStr,categoryStr,myframe;
@synthesize web2Loaded,web3Loaded;

- (id)initWithURL:(NSURL*)URL another:(NSURL*)anotherURL other:(NSURL *)otherURL
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTitle:(NSString *)title withSeg:(NSArray *)seg withCate:(NSArray *)cate withFrame:(CGRect)frame {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.title = title;
        self.myframe = frame;
        segStr = [[NSMutableArray alloc] init];
        categoryStr = [[NSMutableArray alloc] init];
        segStr = [seg mutableCopy];
        categoryStr = [cate mutableCopy];
        
        webVC1 = [[GHRootViewController alloc] initWithTitle:@"" withUrl:categoryStr[0]];
        webVC2 = [[GHRootViewController alloc] initWithTitle:@"" withUrl:categoryStr[1]];
        webVC3 = [[GHRootViewController alloc] initWithTitle:@"" withUrl:categoryStr[2]];
        
        webVC2.view.hidden = YES;
        webVC3.view.hidden = YES;
        
        web2Loaded = NO;
        web3Loaded = NO;
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = myframe;
    
    //添加第一页刷新与后退按钮
    UIView *backItem1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backItem1 setMenuActionWithBlock:^{
        [[webVC1 mainWebView] goBack];
    }];
    UIImageView *backIcon1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backIcon1 setImage:[UIImage imageNamed:@"Retreat"]];
    [backItem1 addSubview:backIcon1];
    
    UIView *forwardItem1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [forwardItem1 setMenuActionWithBlock:^{
        [[webVC1 mainWebView] goForward];
    }];
    UIImageView *forwardIcon1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [forwardIcon1 setImage:[UIImage imageNamed:@"Advance"]];
    [forwardItem1 addSubview:forwardIcon1];
    
    
    UIView *reloadItem1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [reloadItem1 setMenuActionWithBlock:^{
        //[[webVC1 mainWebView] reload];
        [webVC1 reloadClicked];
    }];
    UIImageView *reloadIcon1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [reloadIcon1 setImage:[UIImage imageNamed:@"Refresh"]];
    [reloadItem1 addSubview:reloadIcon1];
    
    webSideMenu1 = [[HMSideMenu alloc] initWithItems:@[backItem1, forwardItem1, reloadItem1]];
    [webSideMenu1 setItemSpacing:5.0f];
    [[webVC1 view] addSubview:webSideMenu1];
    [webSideMenu1 open];
    [self addChildViewController:webVC1];
    [webVC1.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-30)];
    [self.view addSubview:webVC1.view];
    
    
    //添加第二页刷新与后退按钮
    UIView *backItem2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backItem2 setMenuActionWithBlock:^{
        [[webVC2 mainWebView] goBack];
    }];
    UIImageView *backIcon2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backIcon2 setImage:[UIImage imageNamed:@"Retreat"]];
    [backItem2 addSubview:backIcon2];
    
    UIView *forwardItem2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [forwardItem2 setMenuActionWithBlock:^{
        [[webVC2 mainWebView] goForward];
    }];
    UIImageView *forwardIcon2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [forwardIcon2 setImage:[UIImage imageNamed:@"Advance"]];
    [forwardItem2 addSubview:forwardIcon2];
    
    
    UIView *reloadItem2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [reloadItem2 setMenuActionWithBlock:^{
        //[[webVC2 mainWebView] reload];
        [webVC2 reloadClicked];
    }];
    UIImageView *reloadIcon2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [reloadIcon2 setImage:[UIImage imageNamed:@"Refresh"]];
    [reloadItem2 addSubview:reloadIcon2];
    
    webSideMenu2= [[HMSideMenu alloc] initWithItems:@[backItem2, forwardItem2, reloadItem2]];
    [webSideMenu2 setItemSpacing:5.0f];
    [[webVC2 view] addSubview:webSideMenu2];
    [webSideMenu2 open];
    [self addChildViewController:webVC2];
    [webVC2.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44-30)];
    [self.view addSubview:webVC2.view];
    

    //添加第三页刷新与后退按钮
    UIView *backItem3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backItem3 setMenuActionWithBlock:^{
        [[webVC3 mainWebView] goBack];
    }];
    UIImageView *backIcon3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backIcon3 setImage:[UIImage imageNamed:@"Retreat"]];
    [backItem3 addSubview:backIcon3];
    
    UIView *forwardItem3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [forwardItem3 setMenuActionWithBlock:^{
        [[webVC3 mainWebView] goForward];
    }];
    UIImageView *forwardIcon3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [forwardIcon3 setImage:[UIImage imageNamed:@"Advance"]];
    [forwardItem3 addSubview:forwardIcon3];
    
    
    UIView *reloadItem3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [reloadItem3 setMenuActionWithBlock:^{
        //[[webVC3 mainWebView] reload];
        [webVC3 reloadClicked];
    }];
    UIImageView *reloadIcon3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [reloadIcon3 setImage:[UIImage imageNamed:@"Refresh"]];
    [reloadItem3 addSubview:reloadIcon3];
    
    webSideMenu3= [[HMSideMenu alloc] initWithItems:@[backItem3, forwardItem3, reloadItem3]];
    [webSideMenu3 setItemSpacing:5.0f];
    [[webVC3 view] addSubview:webSideMenu3];
    [webSideMenu3 open];
    [self addChildViewController:webVC3];
    [webVC3.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44-30)];
    [self.view addSubview:webVC3.view];


    
    //添加选项卡
    //UIImageView *segBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"segmented-bg.png"]];
    UIView *segBg = [[UIView alloc] init];
    [segBg setFrame:CGRectMake(0, 0, 320, 40)];
    [segBg setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:segBg];
    segmentedPerson = [[AKSegmentedControl alloc] initWithFrame:CGRectMake(4, 6, 312 ,28)];
    segmentedPerson.tag = 30002;
    [segmentedPerson addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    // Setting the resizable background image
    //UIImage *backgroundImage = [UIImage imageNamed:@"Subcategories.png"];
    //[segmentedPerson setBackgroundImage:backgroundImage];
    [segmentedPerson setBackgroundColor:[UIColor colorWithRed:233.0f/255.0f green:235.0f/255.0f blue:228.0f/255.0f alpha:1.0f]];
    // Setting the behavior mode of the control
    [segmentedPerson setSegmentedControlMode:AKSegmentedControlModeSticky];
    
    // Setting the separator image
    //[segmentedNews setSeparatorImage:[UIImage imageNamed:@"segmented-separator.png"]];
    
    UIImage *buttonBackground = [UIImage imageNamed:@"Subcategories.png"];//resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"Subcategories-pressed.png"];
    
    // Button 1
    segOneBtn = [[UIButton alloc] init];
    [segOneBtn setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [segOneBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateHighlighted];
    [segOneBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateSelected];
    [segOneBtn setBackgroundImage:buttonBackgroundPressed forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [segOneBtn setTitle:segStr[0] forState:UIControlStateNormal];
    [segOneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [segOneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [segOneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    //[buttonSocial setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    //[segOneBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    [segOneBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];//FZHuangCao-S09S 17.0
    //[buttonSocial setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    // Button 2
    segTwoBtn = [[UIButton alloc] init];
    [segTwoBtn setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [segTwoBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateHighlighted];
    [segTwoBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateSelected];
    [segTwoBtn setBackgroundImage:buttonBackgroundPressed forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [segTwoBtn setTitle:segStr[1] forState:UIControlStateNormal];
    [segTwoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [segTwoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [segTwoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [segTwoBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
    
    // Button 2
    segThreeBtn = [[UIButton alloc] init];
    [segThreeBtn setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [segThreeBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateHighlighted];
    [segThreeBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateSelected];
    [segThreeBtn setBackgroundImage:buttonBackgroundPressed forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [segThreeBtn setTitle:segStr[2] forState:UIControlStateNormal];
    [segThreeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [segThreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [segThreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [segThreeBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
    
    // Setting the UIButtons used in the segmented control
    [segmentedPerson setButtonsArray:@[segOneBtn,segTwoBtn,segThreeBtn]];
    [segmentedPerson setSelectedIndex:0];
    //[buttonSocial setHighlighted:YES];
    // Adding your control to the view
    [self.view addSubview:segmentedPerson];
    
    [self.webVC1.mainWebView loadRequest:[NSURLRequest requestWithURL:self.webVC1.webURL]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //[self.navigationController.navigationBar setTranslucent:NO];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        //self.parentViewController.navigationItem.titleView = segmentedPerson;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //[self.navigationController.navigationBar setTranslucent:NO];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        //self.parentViewController.navigationItem.titleView = nil;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleMenu {
    if (self.webSideMenu1.isOpen)
        [self.webSideMenu1 close];
    else
        [self.webSideMenu1 open];
    
    if (self.webSideMenu2.isOpen)
        [self.webSideMenu2 close];
    else
        [self.webSideMenu2 open];
    
    if (self.webSideMenu3.isOpen)
        [self.webSideMenu3 close];
    else
        [self.webSideMenu3 open];

}

#pragma mark - AKSegmentedControl callbacks

- (void)segmentedControlValueChanged:(id)sender
{
    AKSegmentedControl *segmented = (AKSegmentedControl *)sender;
    NSLog(@"SegmentedControl : Selected Index %@,%d", [segmented selectedIndexes], segmented.tag);
    
    if ([segmented selectedIndexes].firstIndex == 0) {
        [self.webVC1.view setHidden:NO];
        [self.webVC2.view setHidden:YES];
        [self.webVC3.view setHidden:YES];
    }else if ([segmented selectedIndexes].firstIndex == 1){
        if (!web2Loaded) {
            [self.webVC2.mainWebView loadRequest:[NSURLRequest requestWithURL:self.webVC2.webURL]];
            web2Loaded = YES;
        }
        
        [self.webVC1.view setHidden:YES];
        [self.webVC2.view setHidden:NO];
        [self.webVC3.view setHidden:YES];
    }else if ([segmented selectedIndexes].firstIndex == 2){
        if (!web3Loaded) {
            [self.webVC3.mainWebView loadRequest:[NSURLRequest requestWithURL:self.webVC3.webURL]];
            web3Loaded = YES;
        }
        
        [self.webVC1.view setHidden:YES];
        [self.webVC2.view setHidden:YES];
        [self.webVC3.view setHidden:NO];
    }
}

@end

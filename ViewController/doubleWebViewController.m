//
//  doubleWebViewController.m
//  RaidersSD
//
//  Created by 计 炜 on 13-8-31.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "doubleWebViewController.h"
#import "SVWebViewController.h"
#import "HMSideMenu.h"
#import "Globle.h"

@interface doubleWebViewController ()
- (void)toggleMenu;
@end

@implementation doubleWebViewController
@synthesize bbsViewController,officialWebView,bbsSideMenu,officialSideMenu,segOneBtn,segTwoBtn,segmentedPerson;

- (id)initWithURL:(NSURL*)URL another:(NSURL*)otherURL
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        officialWebView = [[SVWebViewController alloc] initWithURL:URL];
        bbsViewController = [[SVWebViewController alloc] initWithURL:otherURL];
        bbsViewController.view.hidden = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
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
        [[bbsViewController mainWebView] reload];
    }];
    UIImageView *browserIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [browserIcon setImage:[UIImage imageNamed:@"Refresh"]];
    [browserItem addSubview:browserIcon];
    
    bbsSideMenu = [[HMSideMenu alloc] initWithItems:@[twitterItem, emailItem, browserItem]];
    [bbsSideMenu setItemSpacing:5.0f];
    [[bbsViewController mainWebView] addSubview:bbsSideMenu];
    [bbsSideMenu open];
    [self addChildViewController:bbsViewController];
    [bbsViewController.view setFrame:CGRectMake(0, -44, 320, [Globle shareInstance].globleHeight-44-30)];
    [self.view addSubview:bbsViewController.view];
    
    
    //添加刷新与后退按钮
    UIView *backItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backItem setMenuActionWithBlock:^{
        [[officialWebView mainWebView] goBack];
    }];
    UIImageView *backIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backIcon setImage:[UIImage imageNamed:@"Retreat"]];
    [backItem addSubview:backIcon];
    
    UIView *forwardItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [forwardItem setMenuActionWithBlock:^{
        [[officialWebView mainWebView] goForward];
    }];
    UIImageView *forwardIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [forwardIcon setImage:[UIImage imageNamed:@"Advance"]];
    [forwardItem addSubview:forwardIcon];
    
    
    UIView *reloadItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [reloadItem setMenuActionWithBlock:^{
        [[officialWebView mainWebView] reload];
    }];
    UIImageView *reloadIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [reloadIcon setImage:[UIImage imageNamed:@"Refresh"]];
    [reloadItem addSubview:reloadIcon];
    
    officialSideMenu= [[HMSideMenu alloc] initWithItems:@[backItem, forwardItem, reloadItem]];
    [officialSideMenu setItemSpacing:5.0f];
    [[officialWebView mainWebView] addSubview:officialSideMenu];
    [officialSideMenu open];
    [self addChildViewController:officialWebView];
    [officialWebView.view setFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44-30)];
    [self.view addSubview:officialWebView.view];
    
    
    //添加选项卡
    //UIImageView *segBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"segmented-bg.png"]];
    UIView *segBg = [[UIView alloc] init];
    [segBg setFrame:CGRectMake(0, [Globle shareInstance].globleHeight-44-44-30, 320, 30)];
    [segBg setBackgroundColor:[UIColor colorWithRed:233.0f/255.0f green:235.0f/255.0f blue:228.0f/255.0f alpha:1.0f]];
    [self.view addSubview:segBg];
    segmentedPerson = [[AKSegmentedControl alloc] initWithFrame:CGRectMake(10, [Globle shareInstance].globleHeight-44-44-30, 300, 30)];
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
    
    [segOneBtn setTitle:@"官网" forState:UIControlStateNormal];
    [segOneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    //[segOneBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    [segOneBtn.titleLabel setFont:[UIFont fontWithName:@"FZHuangCao-S09S" size:17.0]];
    //[buttonSocial setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    // Button 2
    segTwoBtn = [[UIButton alloc] init];
    [segTwoBtn setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [segTwoBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateHighlighted];
    [segTwoBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateSelected];
    [segTwoBtn setBackgroundImage:buttonBackgroundPressed forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [segTwoBtn setTitle:@"讨论区" forState:UIControlStateNormal];
    [segTwoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [segTwoBtn.titleLabel setFont:[UIFont fontWithName:@"FZHuangCao-S09S" size:17.0]];
    
    // Setting the UIButtons used in the segmented control
    [segmentedPerson setButtonsArray:@[segOneBtn,segTwoBtn]];
    [segmentedPerson setSelectedIndex:0];
    //[buttonSocial setHighlighted:YES];
    // Adding your control to the view
    [self.view addSubview:segmentedPerson];    
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
    if (self.bbsSideMenu.isOpen)
        [self.bbsSideMenu close];
    else
        [self.bbsSideMenu open];
    
    if (self.officialSideMenu.isOpen)
        [self.officialSideMenu close];
    else
        [self.officialSideMenu open];

}

#pragma mark - AKSegmentedControl callbacks

- (void)segmentedControlValueChanged:(id)sender
{
    AKSegmentedControl *segmented = (AKSegmentedControl *)sender;
    NSLog(@"SegmentedControl : Selected Index %@,%d", [segmented selectedIndexes], segmented.tag);
    
    if ([segmented selectedIndexes].firstIndex == 0) {
        [self.officialWebView.view setHidden:NO];
        [self.bbsViewController.view setHidden:YES];
    }else if ([segmented selectedIndexes].firstIndex == 1){
        [self.officialWebView.view setHidden:YES];
        [self.bbsViewController.view setHidden:NO];
    }
}

@end

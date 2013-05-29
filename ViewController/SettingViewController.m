//
//  SettingViewController.m
//  AppGame
//
//  Created by ji wei on 13-4-8.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "SettingViewController.h"
#import "APService.h"

@interface SettingViewController ()
- (void)revealSidebar;
@end

@implementation SettingViewController

@synthesize webURL;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
- (void)viewWillAppear:(BOOL)animated {
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTranslucent:NO];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        //IOS5
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForSelectedRow] animated:YES];
    
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0000];;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle
- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url withRevealBlock:(MySetRevealBlock)revealBlock {
    //if (self = [super initWithNibName:nil bundle:nil]) {
    if (self = [super init]) {
		self.title = title;
        self.webURL = url;
        _revealBlock = [revealBlock copy];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 45, 33);
        [leftButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setShowsTouchWhenHighlighted:YES];
        [leftButton addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *temporaryLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        temporaryLeftBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.leftBarButtonItem = temporaryLeftBarButtonItem;
        
        alerViewManager = [[AlerViewManager alloc] init];
        
        QRootElement *root = [[QRootElement alloc] init];
        root.title = @"设置";
        root.grouped = YES;
        QSection *section = [[QSection alloc] init];
        //QLabelElement *label = [[QLabelElement alloc] initWithTitle:@"我的账号" Value:@"world!"];
        [section addElement:[[QRootElement alloc] initWithJSONFile:@"loginform"]];
        //section.title = @"账号";
        section.headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settinglogo.png"]];
        //[section addElement:label];
        [root addSection:section];
        
        QSection *pushSection = [[QSection alloc] init];
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        BOOL bPush = [standardDefaults boolForKey:@"kPushDefault"];
        QBooleanElement *boolPush = [[QBooleanElement alloc] initWithTitle:@"推送开关" BoolValue:!bPush];

        boolPush.onValueChanged = ^(QRootElement *el){
            NSLog(@"Bool selected! ");
            if (((QBooleanElement *)el).boolValue) {

                [standardDefaults setBool:NO forKey:@"kPushDefault"];
                [standardDefaults synchronize];
                if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != 7) {
                    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                   UIRemoteNotificationTypeSound |
                                                                   UIRemoteNotificationTypeAlert)];
                }
            }else {
                [standardDefaults setBool:YES forKey:@"kPushDefault"];
                [standardDefaults synchronize];
                if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != 0) {
                    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
                }
            }
        };
        
        [pushSection addElement:boolPush];
        
        [root addSection:pushSection];
        
        QSection *aboutusSection = [[QSection alloc] init];
        
        [aboutusSection addElement:[[QRootElement alloc] initWithJSONFile:@"aboutUS"]];
        //[aboutusSection addElement:[[QRootElement alloc] initWithJSONFile:@"disclaimer"]];
        QButtonElement *button = [[QButtonElement alloc] initWithTitle:@"给我们评分"];
        button.onSelected = ^{
            
            //NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
            [standardDefaults setBool:YES forKey:@"kReviewTrollerDoneDefault"];
            [standardDefaults synchronize];
            
            NSString *appId = @"573452997";
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId]]];
        };
        [aboutusSection addElement:button];

        [root addSection:aboutusSection];

        //self.navigationController.navigationItem.leftBarButtonItem = temporaryLeftBarButtonItem;
        [self setRoot:root];
    }
    return self;
}

#pragma mark - Class Methods
- (void)revealSidebar {
	_revealBlock();
}

@end

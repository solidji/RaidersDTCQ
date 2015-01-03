//
//  AppDelegate.m
//  AppGame
//
//  Created by 计 炜 on 13-2-23.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "AppDelegate.h"
#import <AVOSCloud/AVOSCloud.h>

#import "HomeTabViewController.h"
#import "iVersion.h"//StoreKit framework.
#import "APService.h"
//#import <ShareSDK/ShareSDK.h>//ShareSDK_v2.1.0
#import "SVWebViewController.h"
#import "GHRootViewController.h"
#import "GlobalConfigure.h"
#import "Globle.h"

#import "MDSlideNavigationViewController.h"

#pragma mark -
#pragma mark Private Interface
@interface AppDelegate ()
@property (nonatomic, strong) NSDictionary *pushInfo;

@end

@implementation AppDelegate
@synthesize window;
@synthesize pushInfo;
//- (void)dealloc
//{
//    [_window release];
//    [super dealloc];
//}

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//{
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
//    return YES;
//}

#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    NSArray *familyNames =[[NSArray alloc]initWithArray:[UIFont familyNames]];
//    NSArray *fontNames;
//    NSInteger indFamily, indFont;
//
//    for(indFamily=0;indFamily<[familyNames count];++indFamily)
//	{
//        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
//        fontNames =[[NSArray alloc]initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
//        for(indFont=0; indFont<[fontNames count]; ++indFont)
//        {
//            //NSLog(@"Font name: %@",[fontNames objectAtIndex:indFont]);
//        }
//	}
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:4./255 green:160./255 blue:233./255 alpha:1.0]];
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forBarMetrics:UIBarMetricsDefault];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect appBound = [[UIScreen mainScreen] applicationFrame];
    [Globle shareInstance].globleWidth = screenRect.size.width; //屏幕宽度
    [Globle shareInstance].globleHeight = appBound.size.height;  //屏幕高度（无顶栏）
    [Globle shareInstance].globleAllHeight = screenRect.size.height;  //屏幕高度（有顶栏）
    
    
//### AVOS云服务
    [AVOSCloud setApplicationId:@"v0iyd63epej0ynzt7iijfwnq5qdr273fpigwktrngxhjc1ll"
                      clientKey:@"gyfc4wxpn57f1wnajbqp3ejf1tbk6mtrxwhuoek5plnld51g"];

    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];//跟踪统计应用的打开情况
    
//    //ShareSDK
//    [ShareSDK registerApp:@"47cac82fef6"];
//    //添加新浪微博应用
//    [ShareSDK connectSinaWeiboWithAppKey:@"3505932130"
//                               appSecret:@"3d909b20ba5ef58078420f1f940f3765"
//                             redirectUri:@"http://www.appgame.com"];
//    
//    //添加腾讯微博应用
//    [ShareSDK connectTencentWeiboWithAppKey:@"801370579"
//                                  appSecret:@"e0f171e1c89d1b38bcbe54808ad5bbc7" redirectUri:@"http://www.appgame.com"];
    
    // jpush
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(networkDidSetup:) name:kAPNetworkDidSetupNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidClose:) name:kAPNetworkDidCloseNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidRegister:) name:kAPNetworkDidRegisterNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidLogin:) name:kAPNetworkDidLoginNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kAPNetworkDidReceiveMessageNotification object:nil];
    //NSLog(@"openuuid:%@",[APService openUDID]);
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    BOOL bPush = [standardDefaults boolForKey:kPushDefault];
    if (!bPush) {
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)];
    }else {
        if ([application enabledRemoteNotificationTypes] != 0) {
            [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        }
    }
    [APService setupWithOption:launchOptions];
    //[APService setTags:[NSSet setWithObjects:@"tag1", @"tag2", @"tag3", nil] alias:@"别名"];
    
    //提示评分
    NSInteger numberOfExecutions = [standardDefaults integerForKey:kReviewTrollerRunCountDefault] + 1;
    BOOL reviewDone = [standardDefaults boolForKey:kReviewTrollerDoneDefault];
    [standardDefaults setInteger:numberOfExecutions forKey:kReviewTrollerRunCountDefault];
    [standardDefaults synchronize];
    //每运行20次提示评分,如果已经按过yes则不在提示
    if (numberOfExecutions % 50 == 0 && !reviewDone) {
        NSString *title = @"给我们评分";
        NSString *message = @"您的好评将激励我们做的更好.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"不", Nil)
                                                  otherButtonTitles:NSLocalizedString(@"好", Nil), Nil];
        alertView.tag = 101;
        [alertView show];
    }
    
    //iVersion 更新检测
    [iVersion sharedInstance].appStoreID = 837896968;
    
    
    //初始化
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    //处理程序通过推送通知来启动时的情况
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(remoteNotif)
    {
        //Handle remote notification
        [self performSelector:@selector(launchNotification:) withObject:remoteNotif afterDelay:1.0];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //self.window.rootViewController = [[HomeTabViewController alloc] initWithTitle:@"神雕侠侣攻略"];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[HomeTabViewController alloc] initWithTitle:@"刀塔传奇攻略"]];
    [self.window makeKeyAndVisible];
    
    //[NSThread sleepForTimeInterval:1];
	// Make this interesting.
    UIImageView *splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    splashView.image = [UIImage imageNamed:@"Default.png"];
    [self.window addSubview:splashView];
    [self.window bringSubviewToFront:splashView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView: self.window cache:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
    splashView.alpha = 0.0f;
    splashView.frame = CGRectMake(-60, -85, 440, 635);
    [UIView commitAnimations];
//    SVWebViewController *viewController = [[SVWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://dt.appgame.com"]];
//    [(UINavigationController *)self.window.rootViewController pushViewController:viewController animated:YES];
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark AlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
            
            [standardDefaults setBool:YES forKey:kReviewTrollerDoneDefault];
            [standardDefaults synchronize];
            
            NSString *appId = @"837896968";
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId]]];
        }else {
            NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
            
            [standardDefaults setBool:NO forKey:kReviewTrollerDoneDefault];
            [standardDefaults synchronize];
            
        }
    }else if (alertView.tag == 100)//运行状态下收到推送通知,进行询问
    {
        if (buttonIndex == 1){
            [self performSelector:@selector(launchNotification:) withObject:pushInfo afterDelay:1.0];
        }
    }
}
#pragma mark UIApplicationDelegate JPush
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)launchNotification:(NSDictionary *)userInfo
{
    NSLog(@"launchNotification");//仅在程序关闭时收到推送被调用
    NSString *urlField = [userInfo valueForKey:@"url"]; //自定义参数，key是自己定义的
    if (urlField != nil) {
        GHRootViewController *vc = [[GHRootViewController alloc] initWithTitle:@"消息页面" withUrl:urlField];
        [(UINavigationController *)self.window.rootViewController pushViewController:vc animated:YES];
        //[vc.mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlField]]];
    }
//    NSLog(@"launchNotification");//仅在程序关闭时收到推送被调用
//    NSString *urlField = [userInfo valueForKey:@"url"]; //自定义参数，key是自己定义的
//    if (urlField != nil) {
//
//        UINavigationController *pushViewController = [[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"消息页面" withUrl:urlField withRevealBlock:revealBlock]];
//        self.revealController.contentViewController = pushViewController;//设置默认页面
//        
//        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
//                                                                                     action:@selector(dragContentView:)];
//        panGesture.cancelsTouchesInView = YES;
//        //[((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
//        [pushViewController.view addGestureRecognizer:panGesture];
//    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification");//仅在前台运行时收到推送 或 后台收到推送按下显示按钮打开时才被调用
    
    // 取得 APNs 标准信息内容
    pushInfo = userInfo;
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue]; //badge数量
    NSString *sound = [aps valueForKey:@"sound"]; //播放的声音
    
    // 取得自定义字段内容
    NSString *urlField = [userInfo valueForKey:@"url"]; //自定义参数，key是自己定义的
    NSLog(@"content=[%@], badge=[%d], sound=[%@], urlField=[%@]",content,badge,sound,urlField);
    
    // Required
    [APService handleRemoteNotification:userInfo];
    
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    if(appState == UIApplicationStateInactive){
        //NSLog(@"程序在锁屏与后台状态");
        //[self launchNotification:userInfo];
        [self performSelector:@selector(launchNotification:) withObject:userInfo afterDelay:1.0];
    }
    else if(appState == UIApplicationStateBackground)
    {
        //NSLog(@"程序在后台状态");
        [self performSelector:@selector(launchNotification:) withObject:userInfo afterDelay:1.0];
    }
    else if(appState == UIApplicationStateActive)
    {
        //NSLog(@"程序在运行状态");
        NSString *title = @"最新消息";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:content
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"忽略", Nil)
                                                  otherButtonTitles:NSLocalizedString(@"查看", Nil), Nil];
        alertView.tag = 100;
        [alertView show];
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark -

- (void)networkDidSetup:(NSNotification *)notification {
    NSLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {
    NSLog(@"未连接。。。");
}

- (void)networkDidRegister:(NSNotification *)notification {
    NSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {
    NSLog(@"已登录");
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    pushInfo = userInfo;
    NSLog(@"收到消息\ndate:%@\ntitle:%@\ncontent:%@", [dateFormatter stringFromDate:[NSDate date]],title,content);
}

#pragma mark -
#pragma mark - sharesdk
//- (BOOL)application:(UIApplication *)application
//      handleOpenURL:(NSURL *)url
//{
//    return [ShareSDK handleOpenURL:url
//                        wxDelegate:nil];
//}
//
//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation
//{
//    return [ShareSDK handleOpenURL:url
//                 sourceApplication:sourceApplication
//                        annotation:annotation
//                        wxDelegate:nil];
//}

@end

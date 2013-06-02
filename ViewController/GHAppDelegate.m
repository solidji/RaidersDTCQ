//
//  GHAppDelegate.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHAppDelegate.h"
#import "GHMenuCell.h"
#import "GHMenuViewController.h"
#import "GHRootViewController.h"
#import "GHRevealViewController.h"
#import "GHSidebarSearchViewController.h"
#import "GHSidebarSearchViewControllerDelegate.h"
#import "ArticleListViewController.h"
#import "iVersion.h"//StoreKit framework.
#import "APService.h"
#import <ShareSDK/ShareSDK.h>
#import "SettingViewController.h"
#import "PersonalViewController.h"
#import "ActivityViewController.h"

#import "AppDataSouce.h"//for login
#import "GlobalConfigure.h"
#import "IADisqusUser.h"
#import "IADisquser.h"
#import "IADisqusConfig.h"




#pragma mark -
#pragma mark Private Interface
@interface GHAppDelegate () //<GHSidebarSearchViewControllerDelegate>
@property (nonatomic, strong) GHRevealViewController *revealController;
@property (nonatomic, strong) GHSidebarSearchViewController *searchController;
@property (nonatomic, strong) GHMenuViewController *menuController;

//- (void)launchNotification:(NSDictionary *)userInfo;
@property (nonatomic, strong) NSDictionary *pushInfo;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHAppDelegate

#pragma mark Properties
@synthesize window;
@synthesize revealController, searchController, menuController;
@synthesize pushInfo;

#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //ShareSDK
    [ShareSDK registerApp:@"10aa36d1da8"];
    //添加新浪微博应用
    [ShareSDK connectSinaWeiboWithAppKey:@"2637205812"
                               appSecret:@"ae6be1db170fb3eed6115a97120a2a99"
                             redirectUri:@"http://www.appgame.com"];
    
    //添加腾讯微博应用
    [ShareSDK connectTencentWeiboWithAppKey:@"100629026"
                                  appSecret:@"a1088785803ba0c969a693ccdaae4e5a" redirectUri:@"http://www.appgame.com"];
    
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
    [iVersion sharedInstance].appStoreID = 573452997;

    
    //初始化
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
	
	//UIColor *bgColor = [UIColor colorWithRed:(215.0f/255.0f) green:(215.0f/255.0f) blue:(215.0f/255.0f) alpha:1.0f];
    UIColor *bgColor = [UIColor colorWithRed:(46.0f/255.0f) green:(51.0f/255.0f) blue:(57.0f/255.0f) alpha:1.0f];
	self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
	self.revealController.view.backgroundColor = bgColor;
    //self.revealController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Basemap.png"]];

	RevealBlock revealBlock = ^(){
		[self.revealController toggleSidebar:!self.revealController.sidebarShowing 
									duration:kGHRevealSidebarDefaultAnimationDuration];
	};
    
	NSArray *headers = @[
		@"",
		@"任玩堂"
	];
	NSArray *controllers = @[
		@[//[NSNumber numberWithInt:-1]
      [[UINavigationController alloc] initWithRootViewController:[[ActivityViewController alloc] initWithTitle:@"主页" withUser:nil withRevealBlock:revealBlock]],
      [[UINavigationController alloc] initWithRootViewController:[[ArticleListViewController alloc] initWithTitle:@"资讯" withUrl:@"http://www.appgame.com/feed?paged=%d" withRevealBlock:revealBlock]],
      [[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"热门" withUrl:@"http://gl.appgame.com/hot-games.html" withRevealBlock:revealBlock]],
      [[UINavigationController alloc] initWithRootViewController:[[ArticleListViewController alloc] initWithTitle:@"收藏" withUrl:@"Favorites" withRevealBlock:revealBlock]],
      
		],
		@[
            [[UINavigationController alloc] initWithRootViewController:[[PersonalViewController alloc] initWithTitle:@"个人" withUser:nil withRevealBlock:revealBlock]],
            [[UINavigationController alloc] initWithRootViewController:[[SettingViewController alloc] initWithTitle:@"设置" withUrl:@"Setting" withRevealBlock:revealBlock]]
		]
	];
    
	NSArray *cellInfos = @[
		@[
			@{kSidebarCellImageKey: @"Home.png", kSidebarCellTextKey: NSLocalizedString(@"主页", @"")},
            @{kSidebarCellImageKey: @"Information.png", kSidebarCellTextKey: NSLocalizedString(@"资讯", @"")},
            @{kSidebarCellImageKey: @"Hot.png", kSidebarCellTextKey: NSLocalizedString(@"热门", @"")},
            @{kSidebarCellImageKey: @"Collection.png", kSidebarCellTextKey: NSLocalizedString(@"收藏", @"")}
		],
		@[
            @{kSidebarCellImageKey: @"Personal.png", kSidebarCellTextKey: NSLocalizedString(@"个人", @"")},
			@{kSidebarCellImageKey: @"Set-up.png", kSidebarCellTextKey: NSLocalizedString(@"设置", @"")}
		]
	];
	
	// Add drag feature to each root navigation controller
	[controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		[((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2){
			UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController 
																						 action:@selector(dragContentView:)];
			panGesture.cancelsTouchesInView = YES;
			//[((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
            [((UINavigationController *)obj2).view addGestureRecognizer:panGesture];
		}];
	}];
	
//	self.searchController = [[GHSidebarSearchViewController alloc] initWithSidebarViewController:self.revealController];
//	self.searchController.view.backgroundColor = [UIColor clearColor];
//    self.searchController.searchDelegate = self;
//	self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
//	self.searchController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
//	self.searchController.searchBar.backgroundImage = [UIImage imageNamed:@"searchBarBG.png"];
//	self.searchController.searchBar.placeholder = NSLocalizedString(@"Search", @"");
//	self.searchController.searchBar.tintColor = [UIColor colorWithRed:(58.0f/255.0f) green:(67.0f/255.0f) blue:(104.0f/255.0f) alpha:1.0f];
//	for (UIView *subview in self.searchController.searchBar.subviews) {
//		if ([subview isKindOfClass:[UITextField class]]) {
//			UITextField *searchTextField = (UITextField *) subview;
//			searchTextField.textColor = [UIColor colorWithRed:(154.0f/255.0f) green:(162.0f/255.0f) blue:(176.0f/255.0f) alpha:1.0f];
//		}
//	}
//	[self.searchController.searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"searchTextBG.png"] 
//																		resizableImageWithCapInsets:UIEdgeInsetsMake(16.0f, 17.0f, 16.0f, 17.0f)]	
//														  forState:UIControlStateNormal];
//	[self.searchController.searchBar setImage:[UIImage imageNamed:@"searchBarIcon.png"] 
//							 forSearchBarIcon:UISearchBarIconSearch 
//										state:UIControlStateNormal];
	
	self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController 
																		withSearchBar:self.searchController.searchBar 
																		  withHeaders:headers 
																	  withControllers:controllers 
																		withCellInfos:cellInfos];
    kDataSource.menuController = self.menuController;
    //检查并登录disqus
    [standardDefaults setBool:NO forKey:kIfLogin];//每次重新登录
    NSString *disqusUsername = [standardDefaults stringForKey:kUsername];
    NSString *disqusPassword = [standardDefaults stringForKey:kPassword];
//    disqusUsername = @"jw@appgame.com";
//    disqusPassword = @"12161127";
    if (disqusUsername == nil || disqusPassword == nil) {
        disqusUsername = @"appgame";
        disqusPassword = @"kiueo_0903xerw3";
    }
    
    IADisquser *iaDisquser = [[IADisquser alloc] initWithIdentifier:@"disqus.com"];
    [iaDisquser loginWithUsername:disqusUsername password:disqusPassword
                          success:^(AFOAuthCredential *credential) {
                              kDataSource.credentialObject = credential;
                              [standardDefaults setValue:credential.accessToken forKey:kAccessToken];
                              [standardDefaults setBool:YES forKey:kIfLogin];
                              
                              // make the parameters dictionary
                              NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          kDataSource.credentialObject.accessToken, @"access_token",
                                                          //DISQUS_API_SECRET, @"api_secret",
                                                          DISQUS_API_PUBLIC,@"api_key",
                                                          //@"", @"user",
                                                          nil];
                              
                              // send the request
                              [iaDisquser getUsersDetails:parameters
                                                  success:^(NSDictionary *responseDictionary){
                                                      // check the code (success is 0)
                                                      NSNumber *code = [responseDictionary objectForKey:@"code"];
                                                      
                                                      if ([code integerValue] != 0) {   // there's an error
                                                          NSLog(@"disqus账户信息异常");
                                                      }else {
                                                          NSDictionary *responseArray = [responseDictionary objectForKey:@"response"];
                                                          if ([responseArray count] != 0) {
                                                              kDataSource.userObject.name = [responseArray objectForKey:@"name"];
                                                              kDataSource.userObject.about = [responseArray objectForKey:@"about"];
                                                              
                                                              kDataSource.userObject.numFollowers = [responseArray objectForKey:@"numFollowers"];
                                                              kDataSource.userObject.numFollowing = [responseArray objectForKey:@"numFollowing"];
                                                              kDataSource.userObject.numPosts = [responseArray objectForKey:@"numPosts"];
                                                              kDataSource.userObject.numLikesReceived = [responseArray objectForKey:@"numLikesReceived"];
                                                              kDataSource.userObject.userID = [responseArray objectForKey:@"id"];
                                                              kDataSource.userObject.authorAvatar = [[[responseArray objectForKey:@"avatar"] objectForKey:@"large"] objectForKey:@"cache"];
                                                              NSLog(@"disqus账户信息:%@,%@,%@", kDataSource.userObject.name, kDataSource.userObject.authorAvatar,kDataSource.userObject.userID);
                                                              //                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"欢迎回来" message:[NSString stringWithFormat: @"您好 %@", kDataSource.userObject.name] delegate:self cancelButtonTitle:@"好!" otherButtonTitles:nil];
                                                              //                                                 [alert show];
                                                              [self.menuController reloadTable];//刷新侧边栏头像
                                                              
                                                              [self performSelector:@selector(showWelcome) withObject:nil afterDelay:2.4];
                                                          }
                                                      }
                                                  }
                                                     fail:^(NSError *error) {
                                                         NSLog(@"disqus账户信息获取失败:%@",error);
                                                     }];
                          }
                             fail:^(NSError *error) {
                                 NSLog(@"disqus账户登录失败:%@",error);
                             }];
    
    
    //处理程序通过推送通知来启动时的情况    
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(remoteNotif)
    {
        //Handle remote notification
        [self performSelector:@selector(launchNotification:) withObject:remoteNotif afterDelay:1.0];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.revealController;
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
    
    return YES;
}

//#pragma mark GHSidebarSearchViewControllerDelegate
//- (void)searchResultsForText:(NSString *)text withScope:(NSString *)scope callback:(SearchResultsBlock)callback {
//	callback(@[@"现代战争4", @"MC4", @"HOC"]);
//}
//
//- (void)searchResult:(id)result selectedAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"Selected Search Result - result: %@ indexPath: %@", result, indexPath);
//}
//
//- (UITableViewCell *)searchResultCellForEntry:(id)entry atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
//	static NSString* identifier = @"GHSearchMenuCell";
//	GHMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//	if (!cell) {
//		cell = [[GHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//	}
//	cell.textLabel.text = (NSString *)entry;
//	cell.imageView.image = [UIImage imageNamed:@"home.png"];
//	return cell;
//}

#pragma mark AlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];

            [standardDefaults setBool:YES forKey:kReviewTrollerDoneDefault];
            [standardDefaults synchronize];
            
            NSString *appId = @"573452997";
            
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
        RevealBlock revealBlock = ^(){
            [self.revealController toggleSidebar:!self.revealController.sidebarShowing
                                        duration:kGHRevealSidebarDefaultAnimationDuration];
        };
        UINavigationController *pushViewController = [[UINavigationController alloc] initWithRootViewController:[[GHRootViewController alloc] initWithTitle:@"消息页面" withUrl:urlField withRevealBlock:revealBlock]];
        self.revealController.contentViewController = pushViewController;//设置默认页面
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
                                                                                     action:@selector(dragContentView:)];
        panGesture.cancelsTouchesInView = YES;
        //[((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
        [pushViewController.view addGestureRecognizer:panGesture];
    }
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
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"TYPESSSSSS: %d", [application enabledRemoteNotificationTypes]);
    
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
- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:nil];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:nil];
}

#pragma mark -
#pragma mark - userAlerts

- (void)showNewReger
{
    [self addUserMsg:@"10000" withMsg:[NSString stringWithFormat:@"亲爱的%@，您已经注册成功！！",kDataSource.userObject.name]];
}

- (void)showWelcome
{
    [self addUserMsg:@"10000" withMsg:[NSString stringWithFormat:@"亲爱的%@，欢迎回来！！",kDataSource.userObject.name]];
}

- (void)showNewAward
{
    [self addUserMsg:@"20000" withMsg:@"恭喜您获得了新的奖品！！！\n请前往“我的宝贝”查收！"];
}

- (void)showNeedRegMsg
{
    [self addUserMsg:@"30000" withMsg:@"亲爱的用户，\n为了便于您参与我们讨论，请前往注册您的《任玩堂》帐号。"];
}

- (void)showFreeMsg:(NSString *)type withMsg:(NSString *)msg
{
    [self addUserMsg:type withMsg:msg];
}


#pragma mark -
#pragma mark - UserMsg

- (void)addUserMsg:(NSString *)msgType withMsg:(NSString *)msg
{
    if (userMsgArray == nil) {
        userMsgArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    
    for (NSString *temp in userMsgArray) {
        if ([msgType isEqualToString:[temp substringToIndex:5]]) {
            return;
        }
    }
    
    NSInteger msgCount = [userMsgArray count];
    NSString *msgObj = [NSString stringWithFormat:@"%@%@",msgType,msg];
    [userMsgArray addObject:msgObj];
    [self doUserMsgCircle:msgCount];
}

- (void)doUserMsgCircle:(NSInteger)msgCount
{
    if (!ifUserMsgCircleRunning) {
        
        ifUserMsgCircleRunning = YES;
        [self creatUserMsg];
        NSString *msgObj = [userMsgArray objectAtIndex:0];
        NSInteger type = [[msgObj substringToIndex:5] integerValue];
        NSString *msg = [msgObj substringFromIndex:5];
        
        switch (type) {
            case 10000:[userMsgIcon setImage:[UIImage imageNamed:@"GreenAlert.png"]];userMsgLabel.text = msg;break;
            case 20000:[userMsgIcon setImage:[UIImage imageNamed:@"GiftAlert.png"]];userMsgLabel.text = msg;break;
            case 30000:[userMsgIcon setImage:[UIImage imageNamed:@"GreenAlert.png"]];userMsgLabel.text = msg;break;
            case 40000:[userMsgIcon setImage:[UIImage imageNamed:@"YellowAlert.png"]];userMsgLabel.text = msg;break;
            default: break;
        }
        userMsgButton.tag = type;
        [self showUserMsg];
    }
    else {
        NSLog(@"waitUserMsgCircle");
        [self performSelector:@selector(doUserMsgCircle:) withObject:nil afterDelay:msgCount * 7.0];
    }
    
}

- (void)creatUserMsg
{
    if (userMsgView == nil) {
        
        UIImageView *back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UserAlertBack.png"]];
        userMsgView = [[UIView alloc] initWithFrame:CGRectMake((320 - back.frame.size.width) / 2, -90, back.frame.size.width, back.frame.size.height)];
        [userMsgView addSubview:back];

        [self.window addSubview:userMsgView];
        
        userMsgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(14, (userMsgView.frame.size.height - 23) / 2, 23, 23)];
        [userMsgView addSubview:userMsgIcon];
        
        userMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 7, 201, userMsgView.frame.size.height - 14)];
        userMsgLabel.backgroundColor = [UIColor clearColor];
        userMsgLabel.numberOfLines = 0;
        userMsgLabel.textAlignment = UITextAlignmentCenter;
        userMsgLabel.font = [UIFont boldSystemFontOfSize:10.0];
        userMsgLabel.textColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
        userMsgLabel.shadowColor = [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1.0];
        userMsgLabel.shadowOffset = CGSizeMake(0, 1);
        [userMsgView addSubview:userMsgLabel];
        
        //        userMsgButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        //        userMsgButton.frame = CGRectMake(0, userMsgView.frame.origin.y, 320, userMsgView.frame.size.height);
        //        userMsgButton.tag = 10000;
        //        [userMsgButton addTarget:self action:@selector(buttonActon:) forControlEvents:UIControlEventTouchUpInside];
        //        [self.window addSubview:userMsgButton];
        
        cancelUserMsgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //cancelUserMsgButton.frame = CGRectMake(0, 500, 320, 480 - userMsgButton.frame.size.height - 50);
        cancelUserMsgButton.frame = CGRectMake(0, 500+88, 320, [[UIScreen mainScreen] bounds].size.height - userMsgButton.frame.size.height - 50);
        cancelUserMsgButton.tag = 100000;
        [cancelUserMsgButton addTarget:self action:@selector(buttonActon:) forControlEvents:UIControlEventTouchUpInside];
        [self.window addSubview:cancelUserMsgButton];
    }
}


- (void)removeUserMsg
{
    userMsgArray = nil;
    [userMsgView removeFromSuperview];
    userMsgView = nil;
    userMsgLabel = nil;
    //    [userMsgButton release];userMsgButton = nil;
    cancelUserMsgButton = nil;
}


- (void)showUserMsg
{
    [UIView beginAnimations:@"showUserMsg" context:NULL];
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    userMsgView.frame = CGRectMake((320 - userMsgView.frame.size.width) / 2, 18, userMsgView.frame.size.width, userMsgView.frame.size.height);
    //    userMsgButton.frame = CGRectMake(0, 20, 320, userMsgButton.frame.size.height);
    [UIView commitAnimations];
}

- (void)dismissUserMsg
{
    if (cancelUserMsgButton.tag == 100000) {
        return;
    }
    
    //cancelUserMsgButton.frame = CGRectMake(0, 500, 320, 480 - userMsgButton.frame.size.height - 50);
    cancelUserMsgButton.frame = CGRectMake(0, 588, 320, [[UIScreen mainScreen] bounds].size.height - userMsgButton.frame.size.height - 50);
    cancelUserMsgButton.tag = 100000;
    
    [UIView beginAnimations:@"dismissUserMsg" context:NULL];
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    userMsgView.frame = CGRectMake((320 - userMsgView.frame.size.width) / 2, -90, userMsgView.frame.size.width, userMsgView.frame.size.height);
    //    userMsgButton.frame = CGRectMake(0, -90, 320, userMsgButton.frame.size.height);
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if([animationID isEqualToString:@"showUserMsg"])
    {
        //cancelUserMsgButton.frame = CGRectMake(0, userMsgButton.frame.size.height, 320, 480 - userMsgButton.frame.size.height - 50);
        cancelUserMsgButton.frame = CGRectMake(0, userMsgButton.frame.size.height, 320, [[UIScreen mainScreen] bounds].size.height - userMsgButton.frame.size.height - 50);
        cancelUserMsgButton.tag = 99999;
        [self performSelector:@selector(dismissUserMsg) withObject:nil afterDelay:3.2];
    }
    
    if([animationID isEqualToString:@"dismissUserMsg"])
    {
        [userMsgArray removeObjectAtIndex:0];
        ifUserMsgCircleRunning = NO;
        
        if ([userMsgArray count] == 0 && !ifUserMsgCircleRunning) {
            [self removeUserMsg];
        }
    }
}

- (void)buttonActon:(UIButton *)aButton
{
    switch (aButton.tag) {
        case 99999:
        {
            //cancel
            
            [self dismissUserMsg];
            break;
        } 
        default:
            break;
    }
}
///////UserMsg/////////

@end

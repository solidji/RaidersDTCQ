//                                
// Copyright 2011 ESCOZ Inc  - http://escoz.com
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this 
// file except in compliance with the License. You may obtain a copy of the License at 
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "LoginController.h"
#import "LoginInfo.h"
#import "SVWebViewController.h"

#import "AppDataSouce.h"//for login
#import "GlobalConfigure.h"
#import "IADisqusUser.h"
#import "IADisquser.h"
#import "IADisqusConfig.h"

@interface LoginController ()
- (void)onLogin:(QButtonElement *)buttonElement;
- (void)onAbout;
- (void)onBack;
- (void)onSignup:(QButtonElement *)buttonElement;

@end

@implementation LoginController

@synthesize iaDisquser;

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];

    self.quickDialogTableView.backgroundView = nil;
    //self.quickDialogTableView.backgroundColor = [UIColor colorWithHue:0.1174 saturation:0.7131 brightness:0.8618 alpha:1.0000];
    self.quickDialogTableView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0000];
    self.quickDialogTableView.bounces = NO;
    self.quickDialogTableView.styleProvider = self;

    ((QEntryElement *)[self.root elementWithKey:@"login"]).delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.navigationController.navigationBar.tintColor = [UIColor redColor];//[UIColor colorWithRed:187.0/255.0 green:18.0/255.0 blue:30.0/255.0 alpha:1.0000];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 50, 26);
    [leftButton setBackgroundImage:[UIImage imageNamed:@"Return.png"] forState:UIControlStateNormal];
    //[leftButton setBackgroundColor:[UIColor redColor]];
    [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [leftButton setShowsTouchWhenHighlighted:YES];
    [leftButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:@" 设置" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont boldSystemFontOfSize:11]];
    
    UIBarButtonItem *temporaryLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    temporaryLeftBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.leftBarButtonItem = temporaryLeftBarButtonItem;
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关于" style:UIBarButtonItemStylePlain target:self action:@selector(onAbout)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.tintColor = nil;
}

- (void)loginCompleted:(LoginInfo *)info {
    [self loading:NO];
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome" message:[NSString stringWithFormat: @"Hi %@, I hope you're loving QuickDialog! Here's your pass: %@", info.login, info.password] delegate:self cancelButtonTitle:@"YES!" otherButtonTitles:nil];
    //[alert show];
}

- (void)onLogin:(QButtonElement *)buttonElement {

    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
    LoginInfo *info = [[LoginInfo alloc] init];
    [self.root fetchValueUsingBindingsIntoObject:info];
    //[self performSelector:@selector(loginCompleted:) withObject:info afterDelay:2];
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setValue:info.login forKey:kUsername];//记住账号密码,下次直接用此账号登录
    [standardDefaults setValue:info.password forKey:kPassword];
    self.iaDisquser = [[IADisquser alloc] initWithIdentifier:@"disqus.com"];
    [self.iaDisquser loginWithUsername:info.login password:info.password
                          success:^(AFOAuthCredential *credential) {
                              [self loading:NO];
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
                                                              [kDataSource.menuController reloadTable];//刷新侧边栏头像
                                                          }
                                                      }
                                                  }
                                                     fail:^(NSError *error) {
                                                         NSLog(@"disqus账户信息获取失败:%@",error);
                                                     }];

                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录成功" message:[NSString stringWithFormat: @"您好 %@", credential.username] delegate:self cancelButtonTitle:@"好!" otherButtonTitles:nil];
                              [alert show];
                          }
                          fail:^(NSError *error) {
                              [self loading:NO];
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:[NSString stringWithFormat: @"%@,请检查用户名密码", info.login] delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
                              [alert show];
                          }];
}

- (void)onSignup:(QButtonElement *)buttonElement {
    
    SVWebViewController *viewController = [[SVWebViewController alloc] initWithAddress:@"http://disqus.com/next/register/?forum=appgame"];//http://bbs.appgame.com/member.php?mod=register
    
    //NSLog(@"didSelectArticle:%@",aArticle.content);
    [self.navigationController pushViewController:viewController animated:YES];
    [self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForSelectedRow] animated:YES];
}

- (void)onAbout {
    QRootElement *details = [LoginController createDetailsForm];
    [self displayViewControllerForRoot:details];
}

- (void)onBack {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath{
    //cell.backgroundColor = [UIColor colorWithRed:0.9582 green:0.9104 blue:0.7991 alpha:1.0000];

    if ([element isKindOfClass:[QEntryElement class]] || [element isKindOfClass:[QButtonElement class]]){
        cell.textLabel.textColor = [UIColor colorWithRed:0.6033 green:0.2323 blue:0.0000 alpha:1.0000];
    }   
}

+ (QRootElement *)createDetailsForm {
    QRootElement *details = [[QRootElement alloc] init];
    details.presentationMode = QPresentationModeModalForm;
    details.title = @"Details";
    details.controllerName = @"AboutController";
    details.grouped = YES;
    QSection *section = [[QSection alloc] initWithTitle:@"Information"];
    [section addElement:[[QTextElement alloc] initWithText:@"Here's some more info about this app."]];
    [details addSection:section];
    return details;
}

- (BOOL)QEntryShouldChangeCharactersInRangeForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
    NSLog(@"Should change characters");
    return YES;
}

- (void)QEntryEditingChangedForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
    NSLog(@"Editing changed");
}

- (void)QEntryMustReturnForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
    NSLog(@"Must return");

}

@end

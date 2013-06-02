//
//  ActivityViewController.m
//  AppGame
//
//  Created by 计 炜 on 13-5-19.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "ActivityViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"

#import "ArticleItem.h"
#import "ArticleItemCell.h"
#import "ActivityItemCell.h"

#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"
#import "RSSParser.h"
#import "RSSItem.h"
#import "SVWebViewController.h"
#import "CommentViewController.h"
#import "PersonalViewController.h"
#import "LoginController.h"

#import "GlobalConfigure.h"
#import "AppDataSouce.h"
#import "IADisqusConfig.h"
#import "IADisqusUser.h"
#import "IADisquser.h"

@interface ActivityViewController ()
- (void)revealSidebar;
- (void)didTapButton:(id)sender;
- (void)goLoginClicked:(id)sender;
@end

@implementation ActivityViewController

@synthesize headerView,bgImage;
@synthesize pullToRefreshTableView,dUser,avatarImage;
@synthesize following,follower,active,post;

#pragma mark - View lifecycle
- (id)initWithTitle:(NSString *)title withUser:(NSNumber *)userID withRevealBlock:(ActivityRevealBlock)revealBlock {
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = title;
        self.dUser = [[IADisqusUser alloc] init];
        self.dUser.userID = userID;
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
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 45, 33);
        //[rightButton setBackgroundImage:[UIImage imageNamed:@"Comment-Right.png"] forState:UIControlStateNormal];
        [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [rightButton setShowsTouchWhenHighlighted:YES];
        [rightButton addTarget:self action:@selector(goLoginClicked:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setTitle:@"登录" forState:UIControlStateNormal];// 添加文字
        [rightButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        UIBarButtonItem *temporaryRightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        temporaryRightBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.rightBarButtonItem = temporaryRightBarButtonItem;
    }
    alerViewManager = [[AlerViewManager alloc] init];
    ifNeedFristLoading = YES;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0];
    self.following = [[NSMutableArray alloc] init];
    self.follower = [[NSMutableArray alloc] init];
    self.active = [[NSMutableArray alloc] init];
    self.post = [[NSMutableArray alloc] init];
    start = 0;
    receiveMember = 0;
    avatarImage=[[UIImageView alloc] initWithFrame:CGRectMake(18, 120-60, 60, 60)];
    [avatarImage.layer setMasksToBounds:YES];
    [avatarImage.layer setOpaque:NO];
    [avatarImage setBackgroundColor:[UIColor clearColor]];
    [avatarImage.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [avatarImage.layer setBorderWidth: 2.0];
    [avatarImage.layer setCornerRadius:30.0];
    
    // #添加列表
    [pullToRefreshTableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    pullToRefreshTableView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-20) withType: withStateViews];
    pullToRefreshTableView.delegate = self;
    pullToRefreshTableView.dataSource = self;
    pullToRefreshTableView.allowsSelection = YES;
    pullToRefreshTableView.backgroundColor = [UIColor clearColor];
    pullToRefreshTableView.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:244.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
    pullToRefreshTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    pullToRefreshTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [pullToRefreshTableView setHidden:NO];
    [self.view addSubview:pullToRefreshTableView];
    
    //添加ZG平行图
    bgImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [bgImage setImage: [UIImage imageNamed:@"ZGAppGame1.png"]];
    
//    UIImageView *bImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
//    [bImage setImage: [UIImage imageNamed:@"ZGAppGame.png"]];
//    pullToRefreshTableView.tableHeaderView = bImage;
    
    [pullToRefreshTableView addParallelViewWithUIView:bgImage withDisplayRadio:0.375 headerViewStyle:ZGScrollViewStyleCutOffAtMax];    
    //By default, displayRadio is 0.5
    //By default, cutOffAtMax is set to NO
    //Set cutOffAtMax to YES to stop the scrolling when it hits the top.
    
    // 开启后台线程获取数据源
    //[self performSelectorInBackground:@selector(getArticles) withObject:nil];
    [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    //NSLog(@"viewWillAppear");
    //    start = 0;
    //    receiveMember = 0;
    //    ifNeedFristLoading = YES;
    //[self getArticles];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 21.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSObject *headerText = @"";
    if (section == 0) {
        headerText = @"动态";
    }
    UIImageView *cellHeadImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
    [cellHeadImage setImage: [UIImage imageNamed:@"CellHeader.png"]];
    UIView *sectionView = nil;
    if (headerText != [NSNull null]) {
        sectionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 22.0f)];
        //[sectionView addSubview:cellHeadImage];
        sectionView.backgroundColor = [UIColor colorWithRed:(227.0f/255.0f) green:(222.0f/255.0f) blue:(216.0f/255.0f) alpha:1.0f];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f,[UIScreen mainScreen].bounds.size.height, 22.0f)];
        textLabel.text = (NSString *) headerText;
        textLabel.font = [UIFont fontWithName:@"Helvetica" size:([UIFont systemFontSize] * 1.0f)];
        textLabel.textColor = [UIColor blackColor];
        textLabel.backgroundColor = [UIColor clearColor];
        [sectionView addSubview:textLabel];
    }
    //增加竖直分割线
    UIView *verticalLine1 = [[UIView alloc] initWithFrame:CGRectMake(79.0f, 17.0f, 1.0f, 6.0f)];
    verticalLine1.backgroundColor = [UIColor colorWithRed:(232.0f/255.0f) green:(228.0f/255.0f) blue:(224.0f/255.0f) alpha:1.0f];
    [sectionView addSubview:verticalLine1];
    UIView *verticalLine2 = [[UIView alloc] initWithFrame:CGRectMake(80.0f, 17.0f, 1.0f, 6.0f)];
    verticalLine2.backgroundColor = [UIColor colorWithRed:(221.0f/255.0f) green:(217.0f/255.0f) blue:(213.0f/255.0f) alpha:1.0f];
    [sectionView addSubview:verticalLine2];
    UIView *verticalLine3 = [[UIView alloc] initWithFrame:CGRectMake(81.0f, 17.0f, 1.0f, 6.0f)];
    verticalLine3.backgroundColor = [UIColor colorWithRed:(228.0f/255.0f) green:(224.0f/255.0f) blue:(220.0f/255.0f) alpha:1.0f];
    [sectionView addSubview:verticalLine3];
    
    UIImageView *imageType = [[UIImageView alloc] initWithFrame:CGRectMake(72.5, 3.0, 15.0, 15.0)];
    [imageType setContentMode:UIViewContentModeScaleToFill];
    [imageType setBackgroundColor:[UIColor clearColor]];//lightGrayColor
    imageType.image = [UIImage imageNamed:@"Dynamic.png"];

    [sectionView addSubview:imageType];

    return sectionView;
}

//某一行被选中,由ViewController来实现push详细页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ActivityRevealBlock revealBlock = ^(){
        [[self navigationController] popViewControllerAnimated:YES];
    };
    
    if (indexPath.section == 0) {
        ArticleItem *aArticle = [self.active objectAtIndex:indexPath.row];
        SVWebViewController *viewController = [[SVWebViewController alloc] initWithHTMLString:aArticle URL:aArticle.articleURL];
        
        //NSLog(@"didSelectArticle:%@",aArticle.content);
        [self.navigationController pushViewController:viewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else if(indexPath.section == 1){
        if ([self.following count] > indexPath.row) {
            ArticleItem *aArticle = [self.following objectAtIndex:indexPath.row];
            ActivityViewController *viewController = [[ActivityViewController alloc] initWithTitle:aArticle.title
                                                                                          withUser:aArticle.userID withRevealBlock:revealBlock];
            
            //NSLog(@"didSelectArticle:%@",aArticle.content);
            [self.navigationController pushViewController:viewController animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }else if(indexPath.section == 2){
        if ([self.follower count] > indexPath.row) {
            ArticleItem *aArticle = [self.follower objectAtIndex:indexPath.row];
            ActivityViewController *viewController = [[ActivityViewController alloc] initWithTitle:aArticle.title
                                                                                          withUser:aArticle.userID withRevealBlock:revealBlock];
            
            //NSLog(@"didSelectArticle:%@",aArticle.content);
            [self.navigationController pushViewController:viewController animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSString *article = [(ArticleItem *)[self.articles objectAtIndex:indexPath.row] description];
    //    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000);
    //    CGSize size = [article sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    return 80;//计算每一个cell的高度
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if ([post count] == 0 && [follower count] == 0 && [following count] == 0) {
//        //  本方法是为了在数据为空时，让“下拉刷新”视图可直接显示，比较直观
//        tableView.contentInset = UIEdgeInsetsMake(k_STATE_VIEW_HEIGHT, 0, 0, 0);
//    }
    
    if (section == 0) {
        //return MIN(5, [follower count]);
        return [active count];
    }else if (section == 1) {
        //return MIN(5, [follower count]);
        return [following count];
    }else if (section == 2) {
        //return MIN(5, [follower count]);
        return [follower count];
    }
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    ActivityItemCell *cell = (ActivityItemCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ActivityItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //NSLog(@"tag:%ld", (long)tableView.tag);
    if (indexPath.section == 0) {
        // Leave cells empty if there's no data yet
        if ([self.active count] > 0) {
            // Set up the cell...
            if (indexPath.row+1 > [self.active count]) {
                //cell.nameLabel.text = @"";
                //cell.imageView.image = [UIImage imageNamed:@"IconPlaceholder.png"];
                [cell.imageView setHidden:YES];
            }else {
                ArticleItem *aArticle = [self.active objectAtIndex:indexPath.row];
 
                cell.articleLabel.text = aArticle.title;
                cell.creatorLabel.text = aArticle.creator;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MM月dd YYYY"];
                cell.dateLabel.text = [dateFormatter stringFromDate:aArticle.pubDate];
                
                if ([aArticle.category isEqualToString:@"post"]) {
                    cell.imageType.image = [UIImage imageNamed:@"Leave-a-message.png"];
                }else if ([aArticle.category isEqualToString:@"reply"]) {
                    cell.imageType.image = [UIImage imageNamed:@"Share.png"];
                }else if ([aArticle.category isEqualToString:@"thread_like"]) {
                    cell.imageType.image = [UIImage imageNamed:@"Favorite.png"];
                }
                
                [cell.imageCreator setImageWithURL:aArticle.iconURL
                               placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
                
                //[cell.imageView setImageWithURL:aArticle.articleIconURL
                 //           placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
                //[cell.nameLabel setFrame:CGRectMake(8.0, 16.0, 320.0-16.0, 20.0)];
                
                AFHTTPClient *jsonapiClient = [AFHTTPClient clientWithBaseURL:aArticle.articleURL];
                
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                            @"get_posts", @"json",
                                            nil];
                
                // make and send a get request
                if (aArticle.articleIconURL == nil || [aArticle.content isEqualToString:nil]) {
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
                                          NSLog(@"获取文章json异常:%@",aArticle.articleURL);
                                      }else {
                                          
                                          aArticle.articleIconURL = [NSURL URLWithString:[[[responseDictionary objectForKey:@"post"] objectForKey:@"thumbnail"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                          
                                          [cell.imageView setImageWithURL:aArticle.articleIconURL
                                                         placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
                                          aArticle.description = [[responseDictionary objectForKey:@"post"] objectForKey:@"excerpt"];
                                          
                                          aArticle.content = [[responseDictionary objectForKey:@"post"] objectForKey:@"content"];
                                          if (aArticle.content != nil) {
                                              NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"appgame" ofType:@"html"];
                                              NSString *htmlString = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
                                              NSString *contentHtml = @"";
                                              NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                              [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
                                              contentHtml = [contentHtml stringByAppendingFormat:htmlString,
                                                             aArticle.title, aArticle.creator, [dateFormatter stringFromDate:aArticle.pubDate]];
                                              contentHtml = [contentHtml stringByReplacingOccurrencesOfString:@"<!--content-->" withString:aArticle.content];
                                              aArticle.content = contentHtml;
                                          }
                                      }
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      // pass error to the block
                                      NSLog(@"获取文章json失败:%@",error);
                              }];
                }else{
                    [cell.imageView setImageWithURL:aArticle.articleIconURL
                                   placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
                }
                [cell.personalButton addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
                //cell.personalButton.clipsToBounds = YES;
                //[cell.personalButton becomeFirstResponder];
            }
        }else {
            //cell.nameLabel.text = @"";
            //cell.imageView.image = [UIImage imageNamed:@"IconPlaceholder.png"];
            [cell.imageView setHidden:YES];
        }
    }
    return cell;
}

-(void)didTapButton:(id)sender{
    UIButton *myBtn=(UIButton *)sender;
    ActivityItemCell *myCell=(ActivityItemCell *)[myBtn superview];
    NSIndexPath * indexPath = [pullToRefreshTableView indexPathForCell:myCell];
    NSLog(@"您点击了第%d行",indexPath.row);
    PersonalRevealBlock revealBlock = ^(){
        [[self navigationController] popViewControllerAnimated:YES];
    };
    ArticleItem *aArticle = [self.active objectAtIndex:indexPath.row];
    PersonalViewController *viewController = [[PersonalViewController alloc] initWithTitle:aArticle.creator
                                                                                  withUser:aArticle.userID withRevealBlock:revealBlock];
    
    //NSLog(@"didSelectArticle:%@",aArticle.content);
    [self.navigationController pushViewController:viewController animated:YES];
    [pullToRefreshTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)goLoginClicked:(id)sender{

    //NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"loginform" ofType:@"json"];
    NSString *jsonString = [[NSBundle mainBundle] pathForResource:@"loginform" ofType:@"json"];
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonParsingError = nil;
    
    //NSDictionary *jsonRoot = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonParsingError];
    //NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        
    if (jsonParsingError!=nil)
        NSLog(@"Parsing error: %@", jsonParsingError.localizedDescription);
    
    //[NSKeyedUnarchiver unarchiveObjectWithData:data];
    //[NSKeyedUnarchiver unarchiveObjectWithFile:@"loginform.json"];
    LoginController *viewController = [[LoginController alloc] initWithCoder:[NSKeyedUnarchiver unarchiveObjectWithFile:@"loginform.json"]];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark - Table View control

- (void)updateThread:(NSString *)returnKey{
    @autoreleasepool {
        sleep(2);
        switch ([returnKey intValue]) {
            case k_RETURN_REFRESH:
            {
                //[active removeAllObjects];
                start = 0;
                [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
                
                break;
            }
            case k_RETURN_LOADMORE:
            {
                //start = [self.active count]/20 + 1;
                
                //[self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
                break;
            }
            default:
                break;
        }
    }
    [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
}

//- (void)updateThreadHotkey:(NSString *)returnKey{
//    @autoreleasepool {
//        sleep(2);
//        switch ([returnKey intValue]) {
//            case k_RETURN_REFRESH:
//            {
//                start = 0;
//                break;
//            }
//            default:
//                break;
//        }
//    }
//    [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
//}

- (void)updateTableView
{
    if (receiveMember  >= 20)
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

    //if (avatarImage.image == nil) {
        [avatarImage setImageWithURL:[NSURL URLWithString:kDataSource.userObject.authorAvatar]
                placeholderImage:[UIImage imageNamed:@""]];
    //}
    [pullToRefreshTableView addSubview:avatarImage];
}

#pragma mark -
#pragma mark Scroll View Delegate
//-(void)setBackImageFrame:(CGFloat)height originalY:(CGFloat)y
//{
//    [bgImage setFrame:CGRectMake(0, y, 320, height)];
//    
//    //控制一下计算图片高度的次数，防止不必要的计算
//    if(_preHeight != height){
//        //截取图片的中间部分显示
//        CGRect rect = CGRectMake(0, 0, _backImage.size.width, _backImage.size.height);
//        float heightLimit =height*2;
//        if(_backImage.size.width > 640 && _backImage.size.height > heightLimit){
//            rect   = CGRectMake(0, (_backImage.size.height/(_backImage.size.width/640) - heightLimit)/2, _backImage.size.width, heightLimit);
//        }else if(_backImage.size.height > 300){
//            rect  = CGRectMake(0, (_backImage.size.height- heightLimit)/2, _backImage.size.width, heightLimit);
//        }
//        
//        CGImageRef  cgImage  = CGImageCreateWithImageInRect([_backImage CGImage], rect);
//        [_backImageView setImage:[UIImage imageWithCGImage:cgImage]];
//        CGImageRelease(cgImage);
//    }
//    _preHeight = height;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullToRefreshTableView tableViewDidDragging];
//    if(scrollView.contentOffset.y < 0){
//        [self setBackImageFrame:120 - scrollView.contentOffset.y originalY:0];
//    }else {
//        [self setBackImageFrame:120 originalY:(0-scrollView.contentOffset.y)];
//    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //[self loadImagesForOnscreenRows];
}

#pragma mark - Class Methods
- (void)revealSidebar {
	_revealBlock();
}

- (void)getArticles {
    // start activity indicator
    //[[self indicator] startAnimating];
    //[self.pullToRefreshTableView setAlpha:0.5];
    //[pullToRefreshTableView setHidden:YES];
    [alerViewManager showMessage:@"正在加载数据" inView:self.view];
    
    IADisquser *iaDisquser = [[IADisquser alloc] initWithIdentifier:@"disqus.com"];
    
    //if ([dUser.userID isEqualToNumber:[NSNumber numberWithInt:-1]]) {
    // make the parameters dictionary
    NSMutableArray *articleAct = [NSMutableArray array];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kDataSource.credentialObject.accessToken, @"access_token",
                                //DISQUS_API_SECRET, @"api_secret",
                                DISQUS_API_PUBLIC,@"api_key",
                                //dUser.userID, @"user",
                                nil];
    
    // send the request
    [iaDisquser getUsersActivity:parameters
                         success:^(NSDictionary *responseDictionary){
                             // check the code (success is 0)
                             NSNumber *code = [responseDictionary objectForKey:@"code"];
                             
                             if ([code integerValue] != 0) {   // there's an error
                                 NSLog(@"disqus动态列表异常");
                             }else {
                                 NSArray *responseArray = [responseDictionary objectForKey:@"response"];
                                 if ([responseArray count] != 0) {
                                     for (NSDictionary *followingDic in responseArray) {
                                         //[self performSelector:@selector(showWelcome) withObject:nil afterDelay:2.4];
                                         ArticleItem *articleItem = [[ArticleItem alloc] init];
                                         
                                         //articleItem.title = [[followingDic objectForKey:@"object"] objectForKey:@"raw_message"];
                                         articleItem.title = [[[followingDic objectForKey:@"object"] objectForKey:@"thread"] objectForKey:@"title"];
                                         articleItem.category = [followingDic objectForKey:@"type"];
                                         NSDictionary *value = [[followingDic objectForKey:@"object"] objectForKey:@"parent"];
                                         if ((NSNull *)value != [NSNull null]) {
                                             articleItem.category = @"reply";
                                         }
                                         
                                         articleItem.creator = [[[followingDic objectForKey:@"object"] objectForKey:@"author"] objectForKey:@"name"];
                                         articleItem.userID = [[[followingDic objectForKey:@"object"] objectForKey:@"author"] objectForKey:@"id"];
                                         
                                         articleItem.articleURL = [NSURL URLWithString:[[[followingDic objectForKey:@"object"] objectForKey:@"thread"] objectForKey:@"link"]];
                                         articleItem.iconURL = [NSURL URLWithString:[[[[[[followingDic objectForKey:@"object"] objectForKey:@"author"] objectForKey:@"avatar"] objectForKey:@"large"] objectForKey:@"cache"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                         
                                         NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                         NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                                         [df setLocale:locale];
                                         [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                         
                                         articleItem.pubDate = [df dateFromString:[[followingDic objectForKey:@"createdAt"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                                         
                                         //[dateFormatter stringFromDate:aArticle.pubDate];
                                         
                                         NSLog(@"disqus动态列表:%@,%@,%@", articleItem.title, articleItem.creator,articleItem.category);
                                         
                                         [articleAct addObject:articleItem];
                                     }
                                 }
                             }
                             [active removeAllObjects];
                             active = articleAct;
                             [alerViewManager dismissMessageView:self.view];
                             // reload the table
                             [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                         }
                            fail:^(NSError *error) {
                                NSLog(@"disqus动态列表获取失败:%@",error);
                                if ([pullToRefreshTableView isHidden])
                                {
                                    [pullToRefreshTableView setHidden:NO];
                                }
                                [alerViewManager dismissMessageView:self.view];
                                //[alerViewManager showOnlyMessage:@"请求数据失败" inView:self.view];
                                
                                [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                            }];
}

@end

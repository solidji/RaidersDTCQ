//
//  PersonalViewController.m
//  AppGame
//
//  Created by 计 炜 on 13-5-15.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "PersonalViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"

#import "ArticleItem.h"
#import "ArticleItemCell.h"

#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"
#import "RSSParser.h"
#import "RSSItem.h"
#import "SVWebViewController.h"
#import "CommentViewController.h"

#import "GlobalConfigure.h"
#import "AppDataSouce.h"
#import "IADisqusConfig.h"
#import "IADisqusUser.h"
#import "IADisquser.h"

@interface PersonalViewController ()
- (void)revealSidebar;
@end

@implementation PersonalViewController

@synthesize headerView;
@synthesize pullToRefreshTableView,dUser,followingLabel,followerLabel;
@synthesize following,follower,active,post;

#pragma mark - View lifecycle
- (id)initWithTitle:(NSString *)title withUser:(NSNumber *)userID withRevealBlock:(PersonalRevealBlock)revealBlock {
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = title;
        self.dUser = [[IADisqusUser alloc] init];
        self.dUser.userID = userID;
        _revealBlock = [revealBlock copy];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 49, 25);
        [leftButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setShowsTouchWhenHighlighted:YES];
        [leftButton addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *temporaryLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        temporaryLeftBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.leftBarButtonItem = temporaryLeftBarButtonItem;
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
    
    dUser.numFollowing = [[NSNumber alloc] initWithInteger:0];
    dUser.numFollowers = [[NSNumber alloc] initWithInteger:0];
    dUser.numPosts = [[NSNumber alloc] initWithInteger:0];
    dUser.numLikesReceived = [[NSNumber alloc] initWithInteger:0];
    
    followingLabel = [[UILabel alloc] init];
    followerLabel = [[UILabel alloc] init];

    start = 0;
    receiveMember = 0;
    
    // #添加列表
    // 搜索结果
    [self.pullToRefreshTableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    pullToRefreshTableView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-20) withType: withStateViews];
    self.pullToRefreshTableView.tag = 100000;
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
    //UIImageView *bgImage=[[UIImageView alloc] initWithFrame:CGRectMake(-(640-320)/2, -(960-320)/2, 320, 480)];
    UIImageView *bgImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, -240, 320, 480)];
    [bgImage setImage: [UIImage imageNamed:@"ZGLDT.png"]];
    [self.pullToRefreshTableView addParallelViewWithUIView:bgImage withDisplayRadio:0.333333 headerViewStyle:ZGScrollViewStyleDefault];
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
        headerText = [[NSString alloc] initWithString:[NSString stringWithFormat:@"评论 %@",dUser.numPosts]];
    }else if(section == 1) {
        headerText = [[NSString alloc] initWithString:[NSString stringWithFormat:@"关注 %@",dUser.numFollowing]];
    }else if(section == 2) {
        headerText = [[NSString alloc] initWithString:[NSString stringWithFormat:@"粉丝 %@",dUser.numFollowers]];
    }
    UIImageView *bgImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
    [bgImage setImage: [UIImage imageNamed:@"CellHeader.png"]];
    UIView *sectionView = nil;
    if (headerText != [NSNull null]) {
        sectionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 22.0f)];
        [sectionView addSubview:bgImage];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f,[UIScreen mainScreen].bounds.size.height, 22.0f)];
        textLabel.text = (NSString *) headerText;
        textLabel.font = [UIFont fontWithName:@"Helvetica" size:([UIFont systemFontSize] * 1.0f)];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.backgroundColor = [UIColor clearColor];
        [sectionView addSubview:textLabel];
    }
    return sectionView;
}

//某一行被选中,由ViewController来实现push详细页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PersonalRevealBlock revealBlock = ^(){
        [[self navigationController] popViewControllerAnimated:YES];
    };
    
    if (indexPath.section == 0) {
        if ([self.post count] > indexPath.row) {
            ArticleItem *aArticle = [self.post objectAtIndex:indexPath.row];

            CommentViewController *viewController = [[CommentViewController alloc] initWithTitle:aArticle.title withUrl:nil threadID:aArticle.userID];
            
            //NSLog(@"didSelectArticle:%@",aArticle.content);
            [self.navigationController pushViewController:viewController animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }else if(indexPath.section == 1){
        if ([self.following count] > indexPath.row) {
            ArticleItem *aArticle = [self.following objectAtIndex:indexPath.row];
            PersonalViewController *viewController = [[PersonalViewController alloc] initWithTitle:aArticle.title
                                                                                          withUser:aArticle.userID withRevealBlock:revealBlock];
            
            //NSLog(@"didSelectArticle:%@",aArticle.content);
            [self.navigationController pushViewController:viewController animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }else if(indexPath.section == 2){
        if ([self.follower count] > indexPath.row) {
            ArticleItem *aArticle = [self.follower objectAtIndex:indexPath.row];
            PersonalViewController *viewController = [[PersonalViewController alloc] initWithTitle:aArticle.title
                                                                                          withUser:aArticle.userID withRevealBlock:revealBlock];
           
            //NSLog(@"didSelectArticle:%@",aArticle.content);
            [self.navigationController pushViewController:viewController animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSString *article = [(ArticleItem *)[self.articles objectAtIndex:indexPath.row] description];
    //    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000);
    //    CGSize size = [article sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    return 52;//计算每一个cell的高度
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if ([post count] == 0 && [follower count] == 0 && [following count] == 0) {
//        //  本方法是为了在数据为空时，让“下拉刷新”视图可直接显示，比较直观
//        tableView.contentInset = UIEdgeInsetsMake(k_STATE_VIEW_HEIGHT, 0, 0, 0);
//    }

    if (section == 0) {
        //return MIN(5, [follower count]);
        return [post count];
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
    ArticleItemCell *cell = (ArticleItemCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ArticleItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //NSLog(@"tag:%ld", (long)tableView.tag);
    if (indexPath.section == 0) {
        // Leave cells empty if there's no data yet
        if ([self.post count] > 0) {
            // Set up the cell...
            if (indexPath.row+1 > [self.post count]) {
                cell.nameLabel.text = @"";
                cell.imageView.image = [UIImage imageNamed:@"IconPlaceholder.png"];
                [cell.imageView setHidden:YES];
            }else {
                ArticleItem *aArticle = [self.post objectAtIndex:indexPath.row];
                cell.nameLabel.text = aArticle.description;
                cell.articleLabel.text = @"";
                cell.imageView.image = [UIImage imageNamed:@"Leave-a-message.png"];
//                [cell.imageView setImageWithURL:aArticle.iconURL
//                               placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
                
                //[cell.nameLabel setFrame:CGRectMake(8.0, 16.0, 320.0-16.0, 20.0)];
                [cell.imageView setHidden:NO];
            }
        }else {
            cell.nameLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"IconPlaceholder.png"];
            [cell.imageView setHidden:YES];
        }
    }else if(indexPath.section == 1) {
        // Leave cells empty if there's no data yet
        if ([self.following count] > 0) {
            // Set up the cell...
            if (indexPath.row+1 > [self.following count]) {
                cell.nameLabel.text = @"";
                cell.imageView.image = [UIImage imageNamed:@"IconPlaceholder.png"];
                [cell.imageView setHidden:YES];
            }else {
                ArticleItem *aArticle = [self.following objectAtIndex:indexPath.row];
                cell.nameLabel.text = aArticle.title;
                cell.articleLabel.text = aArticle.description;
                [cell.imageView setImageWithURL:aArticle.iconURL
                               placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
                
                //[cell.nameLabel setFrame:CGRectMake(8.0, 16.0, 320.0-16.0, 20.0)];
                [cell.imageView setHidden:NO];
            }
        }else {
            cell.nameLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"IconPlaceholder.png"];
            [cell.imageView setHidden:YES];
        }
    }else if(indexPath.section == 2) {
        // Leave cells empty if there's no data yet
        if ([self.follower count] > 0) {
            // Set up the cell...
            if (indexPath.row+1 > [self.follower count]) {
                cell.nameLabel.text = @"";
                cell.imageView.image = [UIImage imageNamed:@"IconPlaceholder.png"];
                [cell.imageView setHidden:YES];
            }else {
                ArticleItem *aArticle = [self.follower objectAtIndex:indexPath.row];
                cell.nameLabel.text = aArticle.title;
                cell.articleLabel.text = aArticle.description;
                [cell.imageView setImageWithURL:aArticle.iconURL
                               placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
                
                //[cell.nameLabel setFrame:CGRectMake(8.0, 16.0, 320.0-16.0, 20.0)];
                [cell.imageView setHidden:NO];
            }
        }else {
            cell.nameLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"IconPlaceholder.png"];
            [cell.imageView setHidden:YES];
        }
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
//                [follower removeAllObjects];
//                [following removeAllObjects];
//                [post removeAllObjects];
                start = 0;
                [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
                
                break;
            }
            case k_RETURN_LOADMORE:
            {
                //start = [self.follower count]/20 + 1;
                
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
    
    UIImageView *avatarImage=[[UIImageView alloc] initWithFrame:CGRectMake(18, 110, 53, 53)];
    [avatarImage.layer setMasksToBounds:YES];
    [avatarImage.layer setOpaque:NO];
    [avatarImage.layer setCornerRadius:0.5];
    
    [avatarImage setImageWithURL:[NSURL URLWithString:kDataSource.userObject.authorAvatar]
                placeholderImage:[UIImage imageNamed:@""]];
    [pullToRefreshTableView addSubview:avatarImage];
    
    [followingLabel setTextColor:[UIColor whiteColor]];//[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]];
    [followingLabel setFont:[UIFont fontWithName:@"Helvetica" size:20.0]];
    [followingLabel setBackgroundColor:[UIColor clearColor]];
    [followingLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [followingLabel setNumberOfLines:1];
    followingLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"关注 %d",[dUser.numFollowing intValue]]];
    [followingLabel setFrame:CGRectMake(250.0-80.0, 70.0, 320.0-250.0, 40.0)];
    [pullToRefreshTableView addSubview:followingLabel];
    
    [followerLabel setTextColor:[UIColor whiteColor]];//:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]];
    [followerLabel setFont:[UIFont fontWithName:@"Helvetica" size:20.0]];
    [followerLabel setBackgroundColor:[UIColor clearColor]];
    [followerLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [followerLabel setNumberOfLines:1];
    followerLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"粉丝 %d",[dUser.numFollowers intValue]]];
    [followerLabel setFrame:CGRectMake(250.0, 70.0, 320.0-250.0, 40.0)];
    [pullToRefreshTableView addSubview:followerLabel];
}

#pragma mark -
#pragma mark Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullToRefreshTableView tableViewDidDragging];
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
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kDataSource.credentialObject.accessToken, @"access_token",
                                    //DISQUS_API_SECRET, @"api_secret",
                                    DISQUS_API_PUBLIC,@"api_key",
                                    dUser.userID, @"user",
                                    nil];
        
    NSMutableArray *articleFollowing = [NSMutableArray array];
    // make the parameters dictionary
    
    // send the request
    [iaDisquser getUsersFollowing:parameters
                        success:^(NSDictionary *responseDictionary){
                            // check the code (success is 0)
                            NSNumber *code = [responseDictionary objectForKey:@"code"];
                            
                            if ([code integerValue] != 0) {   // there's an error
                                NSLog(@"disqus关注列表异常");
                            }else {
                                NSArray *responseArray = [responseDictionary objectForKey:@"response"];
                                if ([responseArray count] != 0) {
                                    for (NSDictionary *followingDic in responseArray) {
                                        IADisqusUser *followingGuy = [[IADisqusUser alloc] init];
                                        followingGuy.userID = [NSNumber numberWithInteger:[[followingDic objectForKey:@"id"] integerValue]];
                                        followingGuy.name = [followingDic objectForKey:@"name"];
                                        followingGuy.about = [followingDic objectForKey:@"about"];
                                        followingGuy.authorAvatar = [[[followingDic objectForKey:@"avatar"] objectForKey:@"small"] objectForKey:@"cache"];

                                        NSLog(@"disqus关注列表:%@,%@", followingGuy.name, followingGuy.userID);
                                        //[self performSelector:@selector(showWelcome) withObject:nil afterDelay:2.4];
                                        ArticleItem *articleItem = [[ArticleItem alloc] init];
                                        articleItem.title = [followingGuy.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                        articleItem.description = followingGuy.about;
                                        articleItem.userID = followingGuy.userID;
                                        articleItem.iconURL = [NSURL URLWithString:[followingGuy.authorAvatar stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                        [articleFollowing addObject:articleItem];
                                    }
                                }
                            }
                            [following removeAllObjects];
                            following = articleFollowing;
                            dUser.numFollowing = [NSNumber numberWithInt:[following count]];
                            [alerViewManager dismissMessageView:self.view];
                            // reload the table
                            [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                        }
                           fail:^(NSError *error) {
                               NSLog(@"disqus关注列表获取失败:%@",error);
                               if ([pullToRefreshTableView isHidden])
                               {
                                   [pullToRefreshTableView setHidden:NO];
                               }
                               [alerViewManager dismissMessageView:self.view];
                               [alerViewManager showOnlyMessage:@"请求数据失败" inView:self.view];
                               
                               [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                           }];



    NSMutableArray *articleFollowers = [NSMutableArray array];
    // send the request
    [iaDisquser getUsersFollowers:parameters
                          success:^(NSDictionary *responseDictionary){
                              // check the code (success is 0)
                              NSNumber *code = [responseDictionary objectForKey:@"code"];
                              
                              if ([code integerValue] != 0) {   // there's an error
                                  NSLog(@"disqus粉丝列表异常");
                              }else {
                                  NSArray *responseArray = [responseDictionary objectForKey:@"response"];
                                  if ([responseArray count] != 0) {
                                      for (NSDictionary *followingDic in responseArray) {
                                          IADisqusUser *followingGuy = [[IADisqusUser alloc] init];
                                          followingGuy.userID = [followingDic objectForKey:@"id"];
                                          followingGuy.name = [followingDic objectForKey:@"name"];
                                          followingGuy.about = [followingDic objectForKey:@"about"];
                                          followingGuy.authorAvatar = [[[followingDic objectForKey:@"avatar"] objectForKey:@"small"] objectForKey:@"cache"];
                                          
                                          NSLog(@"disqus粉丝列表:%@,%@", followingGuy.name, followingGuy.userID);
                                          //[self performSelector:@selector(showWelcome) withObject:nil afterDelay:2.4];
                                          ArticleItem *articleItem = [[ArticleItem alloc] init];
                                          articleItem.title = [followingGuy.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                          articleItem.description = followingGuy.about;
                                          articleItem.userID = followingGuy.userID;
                                          articleItem.iconURL = [NSURL URLWithString:[followingGuy.authorAvatar stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                          [articleFollowers addObject:articleItem];
                                      }
                                  }
                              }
                              [follower removeAllObjects];
                              follower = articleFollowers;
                              dUser.numFollowers = [NSNumber numberWithInt:[follower count]];
                              [alerViewManager dismissMessageView:self.view];
                              // reload the table
                              [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                          }
                             fail:^(NSError *error) {
                                 NSLog(@"disqus粉丝列表获取失败:%@",error);
                                 if ([pullToRefreshTableView isHidden])
                                 {
                                     [pullToRefreshTableView setHidden:NO];
                                 }
                                 [alerViewManager dismissMessageView:self.view];
                                 [alerViewManager showOnlyMessage:@"请求数据失败" inView:self.view];
                                 
                                 [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                             }];
    
    NSMutableArray *articlePosts = [NSMutableArray array];
    // send the request
    [iaDisquser getUsersPosts:parameters
                          success:^(NSDictionary *responseDictionary){
                              // check the code (success is 0)
                              NSNumber *code = [responseDictionary objectForKey:@"code"];
                              
                              if ([code integerValue] != 0) {   // there's an error
                                  NSLog(@"disqus评论列表异常");
                              }else {
                                  NSArray *responseArray = [responseDictionary objectForKey:@"response"];
                                  if ([responseArray count] != 0) {
                                      for (NSDictionary *followingDic in responseArray) {
                                          //[self performSelector:@selector(showWelcome) withObject:nil afterDelay:2.4];
                                          ArticleItem *articleItem = [[ArticleItem alloc] init];
                                          
                                          articleItem.userID = [followingDic objectForKey:@"thread"];
                                          articleItem.description = [followingDic objectForKey:@"raw_message"];
                                          articleItem.creator = [[followingDic objectForKey:@"author"] objectForKey:@"name"];
                                          articleItem.title = [[[followingDic objectForKey:@"author"] objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                          articleItem.iconURL = [NSURL URLWithString:[[[[followingDic objectForKey:@"author"] objectForKey:@"avatar"] objectForKey:@"cache"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                          
                                          NSLog(@"disqus评论列表:%@,%@", articleItem.title, articleItem.creator);
                                          [articlePosts addObject:articleItem];
                                      }
                                  }
                              }
                              [post removeAllObjects];
                              post = articlePosts;
                              dUser.numPosts = [NSNumber numberWithInt:[post count]];
                              [alerViewManager dismissMessageView:self.view];
                              // reload the table
                              [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                          }
                             fail:^(NSError *error) {
                                 NSLog(@"disqus粉评论列表获取失败:%@",error);
                                 if ([pullToRefreshTableView isHidden])
                                 {
                                     [pullToRefreshTableView setHidden:NO];
                                 }
                                 [alerViewManager dismissMessageView:self.view];
                                 [alerViewManager showOnlyMessage:@"请求数据失败" inView:self.view];
                                 
                                 [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                             }];

}

@end

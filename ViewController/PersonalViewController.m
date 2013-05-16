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
@synthesize pullToRefreshTableView,dUser;
@synthesize following,follower,active;

#pragma mark - View lifecycle
- (id)initWithTitle:(NSString *)title withUser:(NSNumber *)userID withRevealBlock:(PersonalRevealBlock)revealBlock {
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = title;
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
    start = 0;
    receiveMember = 0;
    
    // #添加列表
    // 搜索结果
    [self.pullToRefreshTableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    pullToRefreshTableView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-20-44) withType: withStateViews];
    self.pullToRefreshTableView.tag = 100000;
    pullToRefreshTableView.delegate = self;
    pullToRefreshTableView.dataSource = self;
    pullToRefreshTableView.allowsSelection = YES;
    pullToRefreshTableView.backgroundColor = [UIColor clearColor];
    pullToRefreshTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        headerText = @"动态";
    }else if(section == 1) {
        headerText = @"关注";
    }else if(section == 2) {
        headerText = @"粉丝";
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
    if (tableView.tag == 100000) {
        if ([self.follower count] > indexPath.row) {
            ArticleItem *aArticle = [self.follower objectAtIndex:indexPath.row];
            SVWebViewController *viewController = [[SVWebViewController alloc] initWithHTMLString:aArticle URL:aArticle.articleURL];
            
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
    
    return 53;//计算每一个cell的高度
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 100000) {
        if ([follower count] == 0) {
            //  本方法是为了在数据为空时，让“下拉刷新”视图可直接显示，比较直观
            tableView.contentInset = UIEdgeInsetsMake(k_STATE_VIEW_HEIGHT, 0, 0, 0);
        }
        return MAX(5, [follower count]);
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
    if (tableView.tag == 100000) {
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
                [cell.imageView setImageWithURL:aArticle.iconURL
                               placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
                
                [cell.nameLabel setFrame:CGRectMake(8.0, 16.0, 320.0-16.0, 20.0)];
                [cell.imageView setHidden:YES];
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
                [follower removeAllObjects];
                start = 0;
                [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
                
                break;
            }
            case k_RETURN_LOADMORE:
            {
                start = [self.follower count]/20 + 1;
                
                [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
                break;
            }
            default:
                break;
        }
    }
    [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
}

- (void)updateThreadHotkey:(NSString *)returnKey{
    @autoreleasepool {
        sleep(2);
        switch ([returnKey intValue]) {
            case k_RETURN_REFRESH:
            {
                start = 0;                
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
    
    NSMutableArray *article = [NSMutableArray array];
    
    IADisquser *iaDisquser = [[IADisquser alloc] initWithIdentifier:@"disqus.com"];
    // make the parameters dictionary
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kDataSource.credentialObject.accessToken, @"access_token",
                                //DISQUS_API_SECRET, @"api_secret",
                                DISQUS_API_PUBLIC,@"api_key",
                                dUser.userID, @"user",
                                nil];
    
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
                                        followingGuy.userID = [followingDic objectForKey:@"id"];
                                        followingGuy.name = [followingDic objectForKey:@"name"];
                                        NSLog(@"disqus关注列表:%@,%@", followingGuy.name, followingGuy.userID);
                                        //[self performSelector:@selector(showWelcome) withObject:nil afterDelay:2.4];
                                        ArticleItem *articleItem = [[ArticleItem alloc] init];
                                        articleItem.title = followingGuy.name;
                                        [article addObject:articleItem];
                                    }
                                }
                            }
                            [follower removeAllObjects];
                            follower = article;
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
}

@end

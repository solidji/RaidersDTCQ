//
//  ArticleListViewController.m
//  AppGame
//
//  Created by 计 炜 on 13-3-2.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "ArticleListViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ArticleItemCell.h"
#import "ArticleItem.h"
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"
#import "RSSParser.h"
#import "RSSItem.h"
#import "SVWebViewController.h"

#define CELL_CONTENT_WIDTH  320.0-65
#define CELL_CONTENT_MARGIN 4.0

@interface ArticleListViewController ()
- (void)revealSidebar;
- (void)getArticles;
- (void)getPromos;
@end

@implementation ArticleListViewController

@synthesize articles,pullToRefreshTableView,webURL,promos,headerView;

#pragma mark - View lifecycle
- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url withRevealBlock:(MyRevealBlock)revealBlock {
    if (self = [super initWithNibName:nil bundle:nil]) {
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
    }
    alerViewManager = [[AlerViewManager alloc] init];
    ifNeedFristLoading = YES;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:237.0f/255 green:237.0f/255 blue:237.0f/255 alpha:1.0];
    articles = [[NSMutableArray alloc] init];
    promos = [[NSMutableArray alloc] init];
    start = 0;
    receiveMember = 0;
    //    pullToRefreshTableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
    //    pullToRefreshTableView.delegate = self;
    //    pullToRefreshTableView.dataSource = self;
    //    pullToRefreshTableView.backgroundColor = [UIColor clearColor];
    //    [self.view addSubview:pullToRefreshTableView];
    
    [self.pullToRefreshTableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    pullToRefreshTableView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-20) withType: withStateViews];
    pullToRefreshTableView.delegate = self;
    pullToRefreshTableView.dataSource = self;
    pullToRefreshTableView.allowsSelection = YES;
    pullToRefreshTableView.backgroundColor = [UIColor clearColor];
    pullToRefreshTableView.backgroundColor = [UIColor colorWithRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
    pullToRefreshTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    pullToRefreshTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [pullToRefreshTableView setHidden:NO];
    [self.view addSubview:pullToRefreshTableView];
    
    //UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getarticles)];
    //[self.navigationItem setRightBarButtonItem:refresh];
    
    // #添加推广头HeaderView
    headerView = [[TableHeaderView alloc] initWithFrame: CGRectMake(0, 0, 320, 120) withDataSource: self withPageControlType:@"type"];
    //[self.view addSubview:headerView];
    pullToRefreshTableView.tableHeaderView = headerView;
    
    // get array of articles
    // 开启后台线程获取数据源
    [self performSelectorInBackground:@selector(getPromos) withObject:nil];
    [self getArticles];
}

//- (void)loadView {
//    //NSLog(@"loadView");
//}

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

//某一行被选中,由ViewController来实现push详细页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ArticleItem *aArticle = [self.articles objectAtIndex:indexPath.row];
    SVWebViewController *viewController = [[SVWebViewController alloc] initWithHTMLString:aArticle URL:aArticle.articleURL];
    
    //NSLog(@"didSelectArticle:%@",aArticle.content);
    [self.navigationController pushViewController:viewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSString *article = [(ArticleItem *)[self.articles objectAtIndex:indexPath.row] description];
    //    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000);
    //    CGSize size = [article sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    return 160.0f;//计算每一个cell的高度
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([articles count] == 0) {
        //  本方法是为了在数据未空时，让“下拉刷新”视图可直接显示，比较直观
        tableView.contentInset = UIEdgeInsetsMake(k_STATE_VIEW_HEIGHT, 0, 0, 0);
    }
    return [articles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    ArticleItemCell *cell = (ArticleItemCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ArticleItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // Leave cells empty if there's no data yet
    int nodeCount = [self.articles count];
    
    if (nodeCount > 0)
	{
        // Set up the cell...
        ArticleItem *aArticle = [self.articles objectAtIndex:indexPath.row];
        cell.descriptLabel.text = aArticle.description;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        cell.dateLabel.text = [dateFormatter stringFromDate:aArticle.pubDate];
        
        cell.creatorLabel.text = aArticle.creator;
        //        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000);
        //        CGSize size = [aArticle.description sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        cell.articleLabel.text = aArticle.title;
        //        cell.articleLabel.frame = CGRectMake(4.0, 52.0,
        //                                             CELL_CONTENT_WIDTH - (2 * CELL_CONTENT_MARGIN),
        //                                             45.0 + CELL_CONTENT_MARGIN);
        
        // Only load cached images; defer new downloads until scrolling ends
        //当tableview停下来的时候才下载缩略图
        //if (pullToRefreshTableView.dragging == NO && pullToRefreshTableView.decelerating == NO)
        [cell.imageView setImageWithURL:aArticle.iconURL
                       placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
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
                [articles removeAllObjects];
                [promos removeAllObjects];
                start = 0;
                [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(getPromos) withObject:nil waitUntilDone:NO];
                break;
            }
            case k_RETURN_LOADMORE:
            {
                start = [self.articles count]/20 + 1;
                
                [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
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

#pragma mark -
#pragma mark Scroll Page View Delegate

- (void)resetPromoPage
{
    //TableHeaderView *header = (TableHeaderView *)pullToRefreshTableView.tableHeaderView;
    [headerView resetPage];
}


- (void)reloadPromoPage:(NSInteger)page
{
    //TableHeaderView *header = (TableHeaderView *)pullToRefreshTableView.tableHeaderView;
    [headerView reloadPage:page];
}

//有多少页
- (int)numberOfPages
{
    if ([self.promos count] == 0) {
        return 1;
    }
    return MIN(5, [self.promos count]);
}

//每页的图片
- (UIImageView *)imageAtIndex:(int)index
{
    NSLog(@"index == %d",index);
    
    if([self.promos count] > index)
    {
        ArticleItem *aArticle = [self.promos objectAtIndex:index];
        //return  [UIImage imageWithContentsOfFile:object.iconURL];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 120.0f)];
        [imageView setImageWithURL:aArticle.iconURL
                  placeholderImage:[UIImage imageNamed:@"tableHeadHolder.png"]];
        
        /*异步加回调
         NSURL *url = [NSURL URLWithString:@图片的绝对路径"];
         NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
         [imageView setImageWithURLRequest:request placeholderImage:nil
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         NSLog(@"图片下载成功！do something");
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         NSLog(@图片下载成功！do something"");
         }];""*/
        return imageView;
    }else {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 120.0f)];
        imageView.image = [UIImage imageNamed:@"tableHeadHolder.png"];
    }
    
    return nil;
}

//需要下载
- (void)pageImageNeedDownlod:(NSInteger)index
{
    if(index < [self.promos count])
    {
        //ArticleItem *aArticle = [self.articles objectAtIndex:index];
        [self reloadPromoPage:index];
        //[self startImageDownload:object withType:ImageDownloaderTypePromoImage forIndexPath:[NSIndexPath indexPathForRow:index inSection:5]];
    }
}

//被点击
- (void)pageDidSelceted:(NSInteger)index
{
    ArticleItem *aArticle = [self.promos objectAtIndex:index];
    
    if (aArticle.content != nil) {
        SVWebViewController *viewController = [[SVWebViewController alloc] initWithHTMLString:aArticle URL:aArticle.articleURL];
        [self.navigationController pushViewController:viewController animated:YES];
    }else {
        SVWebViewController *viewController = [[SVWebViewController alloc] initWithURL:aArticle.articleURL];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    //NSLog(@"didSelectArticle:%@",aArticle.content);
    
    //[pullToRefreshTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Class Methods
- (void)revealSidebar {
	_revealBlock();
}

- (void)getPromos {
    NSMutableArray *article = [NSMutableArray array];
    NSString *urlString =  [NSString stringWithFormat:@"http://gl.appgame.com/focus.rss"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [RSSParser parseRSSFeedForRequest:request success:^(NSArray *feedItems) {
        
        //you get an array of RSSItem
        receiveMember = [feedItems count];
        if (receiveMember > 0) {
            for (RSSItem *feedItem in feedItems) {
                ArticleItem *articleItem = [[ArticleItem alloc] init];
                articleItem.title = feedItem.title;
                articleItem.description = feedItem.itemDescription;
                articleItem.creator = feedItem.author;
                articleItem.pubDate = feedItem.pubDate;
                articleItem.content = feedItem.content;
                articleItem.articleURL = feedItem.link;
                
                if ([feedItem imagesFromItemDescription].count != 0) {
                    NSMutableString *iconURL = [NSMutableString stringWithString:[[feedItem imagesFromItemDescription] objectAtIndex:0]];
                    
                    //中文URL编码
                    articleItem.iconURL = [NSURL URLWithString:[iconURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
                else
                {
                    articleItem.iconURL = [NSURL URLWithString:@"IconPlaceholder.png"];
                }
                
                //过滤掉description里的缩略图与content里的android与winphone图片
                NSError *error;
                
                NSRegularExpression *regexThumbnail = [NSRegularExpression
                                                       regularExpressionWithPattern:@"(<div><img).*(https?)\\S*(png|jpg|jpeg|gif).*(<div.*</div>)*.*(</div>)"
                                                       options:NSRegularExpressionCaseInsensitive
                                                       error:&error];
                if (feedItem.itemDescription != nil) {
                    [regexThumbnail enumerateMatchesInString:feedItem.itemDescription
                                                     options:0
                                                       range:NSMakeRange(0, feedItem.itemDescription.length)
                                                  usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                                      //[imagesURLStringArray addObject:[feedItem.itemDescription substringWithRange:result.range]];
                                                      articleItem.description = [articleItem.description stringByReplacingOccurrencesOfString:[feedItem.itemDescription substringWithRange:result.range] withString:@""];
                                                      
                                                      articleItem.content = [articleItem.content stringByReplacingOccurrencesOfString:[feedItem.itemDescription substringWithRange:result.range] withString:@""];
                                                      
                                                      //NSLog(@"des:%@,%@",articleItem.description,[feedItem.itemDescription substringWithRange:result.range]);
                                                  }];
                }
                NSRegularExpression *regexAndroid = [NSRegularExpression
                                                     regularExpressionWithPattern:@"(<div.*\\n*.*)(www\\.appgame\\.com/source/html5/images/appgame-download-android-s2\\.png|www\\.appgame\\.com/source/html5/images/appgame-download-wphone\\.png).*\\n*.*(<div.*\\n*.*</div>)*.*\\n*.*(</div>)"
                                                     options:NSRegularExpressionCaseInsensitive
                                                     error:&error];
                if (feedItem.content != nil) {
                    [regexAndroid enumerateMatchesInString:feedItem.content
                                                   options:0
                                                     range:NSMakeRange(0, feedItem.content.length)
                                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                                    articleItem.content = [articleItem.content stringByReplacingOccurrencesOfString:[feedItem.content substringWithRange:result.range] withString:@""];
                                                    
                                                    NSLog(@"content:%@,%@",articleItem.content,[feedItem.content substringWithRange:result.range]);
                                                }];
                }
                //return [NSArray arrayWithArray:imagesURLStringArray];
                if (articleItem.content != nil) {
                    NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"appgame" ofType:@"html"];
                    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
                    NSString *contentHtml = @"";
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
                    contentHtml = [contentHtml stringByAppendingFormat:htmlString,
                                   articleItem.title, @" ", [dateFormatter stringFromDate:articleItem.pubDate]];
                    contentHtml = [contentHtml stringByReplacingOccurrencesOfString:@"<!--content-->" withString:articleItem.content];
                    articleItem.content = contentHtml;
                }
                [article addObject:articleItem];
            }
            [self.promos removeAllObjects];
            for (ArticleItem *articleItem in article) {
                [self.promos addObject:articleItem];
            }
        }
        // reload the table
        [self resetPromoPage];
        
    } failure:^(NSError *error) {
        //something went wrong
        NSLog(@"Failure: %@", error);
    }];
}

- (void)getArticles {
    // start activity indicator
    //[[self indicator] startAnimating];
    //[self.pullToRefreshTableView setAlpha:0.5];
    //[pullToRefreshTableView setHidden:YES];
    [alerViewManager showMessage:@"正在加载数据" inView:self.view];
    
    NSMutableArray *article = [NSMutableArray array];
    if ([self.webURL isEqual: @"Favorites"]) {
        //从standardDefaults中读取收藏列表
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        
        NSData *udObject = [standardDefaults objectForKey:@"Favorites"];
        NSArray *udData = [NSKeyedUnarchiver unarchiveObjectWithData:udObject];
        self.articles = [NSMutableArray arrayWithArray:udData];
        [alerViewManager dismissMessageView:self.view];
        [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
        if([self.articles count] < 20)
        {
            if ([pullToRefreshTableView isHidden])
            {
                [pullToRefreshTableView setHidden:NO];
            }
        }
        [alerViewManager dismissMessageView:self.view];
        //[alerViewManager showOnlyMessage:@"暂无更多数据" inView:self.view];
        return;
    }
    NSString *urlString =  [NSString stringWithFormat:webURL, start];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [RSSParser parseRSSFeedForRequest:request success:^(NSArray *feedItems) {
        
        //you get an array of RSSItem
        receiveMember = [feedItems count];
        if (receiveMember > 0) {
            for (RSSItem *feedItem in feedItems) {
                ArticleItem *articleItem = [[ArticleItem alloc] init];
                articleItem.title = [feedItem.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                articleItem.description = feedItem.itemDescription;
                articleItem.creator = feedItem.author;
                articleItem.pubDate = feedItem.pubDate;
                articleItem.content = feedItem.content;
                articleItem.articleURL = feedItem.link;
                articleItem.category = @"";
                
                if ([feedItem imagesFromItemDescription].count != 0) {
                    NSMutableString *iconURL = [NSMutableString stringWithString:[[feedItem imagesFromItemDescription] objectAtIndex:0]];
                    //[iconURL insertString:@"-150x150" atIndex:[[[feedItem imagesFromItemDescription] objectAtIndex:0] length]-4];
                    //NSLog(@"title  :%@", feedItem.title);
                    //NSLog(@"iconURL:%@", iconURL);
                    //中文URL编码
                    articleItem.iconURL = [NSURL URLWithString:[iconURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
                else
                {
                    articleItem.iconURL = [NSURL URLWithString:@"IconPlaceholder.png"];
                }
                
                //过滤掉description里的缩略图与content里的android与winphone图片
                NSError *error;
                
                NSRegularExpression *regexThumbnail = [NSRegularExpression
                                                       regularExpressionWithPattern:@"(<div><img).*(https?)\\S*(png|jpg|jpeg|gif).*(<div.*</div>)*.*(</div>)"
                                                       options:NSRegularExpressionCaseInsensitive
                                                       error:&error];
                [regexThumbnail enumerateMatchesInString:feedItem.itemDescription
                                                 options:0
                                                   range:NSMakeRange(0, feedItem.itemDescription.length)
                                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                                  //[imagesURLStringArray addObject:[feedItem.itemDescription substringWithRange:result.range]];
                                                  articleItem.description = [articleItem.description stringByReplacingOccurrencesOfString:[feedItem.itemDescription substringWithRange:result.range] withString:@""];
                                                  
                                                  articleItem.content = [articleItem.content stringByReplacingOccurrencesOfString:[feedItem.itemDescription substringWithRange:result.range] withString:@""];
                                                  
                                                  //NSLog(@"des:%@,%@",articleItem.description,[feedItem.itemDescription substringWithRange:result.range]);
                                              }];
                
                NSRegularExpression *regexAndroid = [NSRegularExpression
                                                     regularExpressionWithPattern:@"(<div.*\\n*.*)(www\\.appgame\\.com/source/html5/images/appgame-download-android-s2\\.png|www\\.appgame\\.com/source/html5/images/appgame-download-wphone\\.png).*\\n*.*(<div.*\\n*.*</div>)*.*\\n*.*(</div>)"
                                                     options:NSRegularExpressionCaseInsensitive
                                                     error:&error];
                [regexAndroid enumerateMatchesInString:feedItem.content
                                               options:0
                                                 range:NSMakeRange(0, feedItem.content.length)
                                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                                articleItem.content = [articleItem.content stringByReplacingOccurrencesOfString:[feedItem.content substringWithRange:result.range] withString:@""];
                                                
                                                //NSLog(@"content:%@,%@",articleItem.content,[feedItem.content substringWithRange:result.range]);
                                            }];
                
                //return [NSArray arrayWithArray:imagesURLStringArray];
                if (articleItem.content != nil) {
                    NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"appgame" ofType:@"html"];
                    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
                    NSString *contentHtml = @"";
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
                    contentHtml = [contentHtml stringByAppendingFormat:htmlString,
                                   articleItem.title, articleItem.creator, [dateFormatter stringFromDate:articleItem.pubDate]];
                    contentHtml = [contentHtml stringByReplacingOccurrencesOfString:@"<!--content-->" withString:articleItem.content];
                    articleItem.content = contentHtml;
                }
                [article addObject:articleItem];
            }
            if (start < 2) {
                [self.articles removeAllObjects];
                if (ifNeedFristLoading) {
                    //[self.pullToRefreshTableView reloadData];
                    //第一次显示时 跳到首行
                    [self.pullToRefreshTableView setContentOffset:CGPointMake(0,0)];
                    //[self.pullToRefreshTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                }
                self.articles = article;
                if ([pullToRefreshTableView isHidden])
                {
                    [pullToRefreshTableView setHidden:NO];
                }
                
                [alerViewManager dismissMessageView:self.view];
            }
            else
            {
                for (ArticleItem *articleItem in article) {
                    [self.articles addObject:articleItem];
                }
                if ([pullToRefreshTableView isHidden])
                {
                    [pullToRefreshTableView setHidden:NO];
                }
                [alerViewManager dismissMessageView:self.view];
            }
        }
        else
        {
            if([self.articles count] < 20)
            {
                if ([pullToRefreshTableView isHidden])
                {
                    [pullToRefreshTableView setHidden:NO];
                }
            }
            [alerViewManager dismissMessageView:self.view];
            //[alerViewManager showOnlyMessage:@"暂无更多数据" inView:self.view];
        }
        //self.articles = [[articles reverseObjectEnumerator] allObjects];
        ifNeedFristLoading = NO;
        // reload the table
        [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
        
    } failure:^(NSError *error) {
        
        //something went wrong
        NSLog(@"Failure: %@", error);
        if ([pullToRefreshTableView isHidden])
        {
            [pullToRefreshTableView setHidden:NO];
        }
        [alerViewManager dismissMessageView:self.view];
        [alerViewManager showOnlyMessage:@"请求数据失败" inView:self.view];
        
        //        if([self.articles count] == 0) {
        //            ifNeedFristLoading = YES;
        //        }
        
        [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
        
        // alert the error
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Occured"
        //                                                        message:[error localizedDescription]
        //                                                       delegate:nil
        //                                              cancelButtonTitle:@"OK"
        //                                              otherButtonTitles:nil];
        //        [alert show];
    }];
}

@end

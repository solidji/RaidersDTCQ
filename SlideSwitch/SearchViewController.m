//
//  SearchViewController.m
//  RaidersDOTA
//
//  Created by 计 炜 on 13-7-22.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "SearchViewController.h"
#import "ArticleItem.h"
#import "SVWebViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchItemCell.h"
#import "Globle.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"
#import "RSSParser.h"
#import "RSSItem.h"


@interface SearchViewController ()
- (void)getArticles;//搜索文章
@end

@implementation SearchViewController
@synthesize searchStr,searchView,articles;

- (id)initWithTitle:(NSString *)title withFrame:(CGRect)frame {
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = title;
        self.view.frame = frame;
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 21, 21);
        [leftButton setBackgroundImage:[UIImage imageNamed:@"Return.png"] forState:UIControlStateNormal];
        [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setShowsTouchWhenHighlighted:YES];
        [leftButton addTarget:self action:@selector(goPopClicked:) forControlEvents:UIControlEventTouchUpInside];
        //[leftButton setTitle:@" 后退" forState:UIControlStateNormal];
        //[leftButton.titleLabel setFont:[UIFont boldSystemFontOfSize:11]];
        //leftButton.titleLabel.textColor = [UIColor yellowColor];
        
        UIBarButtonItem *temporaryLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        temporaryLeftBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.leftBarButtonItem = temporaryLeftBarButtonItem;
    }

    self.searchStr = NULL;
    self.articles = [[NSMutableArray alloc] init];
    alerViewManager = [[AlerViewManager alloc] init];
    start = 0;
    receiveMember = 0;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithRed:211.0f/255.0f green:214.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
    self.view.frame = CGRectMake(0, 0, [Globle shareInstance].globleWidth, [Globle shareInstance].globleHeight);
    
    self.searchView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(0, 40, self.view.bounds.size.width,[Globle shareInstance].globleHeight-40) withType: withStateViews];
    self.searchView.tag = 100000;
    
    [self.searchView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    searchView.delegate = self;
    searchView.dataSource = self;
    searchView.allowsSelection = YES;
    searchView.backgroundColor = [UIColor clearColor];
    searchView.backgroundColor = [UIColor colorWithRed:211.0f/255.0f green:214.0f/255.0f blue:219.0f/255.0f alpha:0.7f];
    searchView.separatorStyle = UITableViewCellSeparatorStyleNone;//选中时cell样式
    searchView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [searchView setHidden:NO];
    //searchView.alpha = 0.7f;
    [self.view addSubview:searchView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0.0, self.view.bounds.size.width, 40)];
    _searchBar.placeholder=@"玩游戏卡住了?搜一下!";
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = NO;
    _searchBar.barStyle=UIBarStyleDefault;
    _searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:_searchBar];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(goPopClicked:)];
    swipeGesture.delegate = self;
    [swipeGesture setDirection:(UISwipeGestureRecognizerDirectionRight)];
    swipeGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:swipeGesture];
    
    // get array of articles
    [self performSelectorInBackground:@selector(getArticles) withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //[self.navigationController.navigationBar setTranslucent:NO];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        //IOS5
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top.png"] forBarMetrics:UIBarMetricsDefault];
        //self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    }
}

- (void)goPopClicked:(UIBarButtonItem *)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [searchView tableViewDidDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSInteger returnKey = [searchView tableViewDidEndDragging];
    
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

#pragma mark -
#pragma mark - Table View control

- (void)updateThread:(NSString *)returnKey{
    @autoreleasepool {
        sleep(2);
        switch ([returnKey intValue]) {
            case k_RETURN_REFRESH:
            {
                [articles removeAllObjects];
                start = 0;
                [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
                
                break;
            }
            case k_RETURN_LOADMORE:
            {
                start = [self.articles count]/10 + 1;
                
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
                [articles removeAllObjects];
                start = 0;
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
    if (receiveMember  >= 10)
    {
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果数据还能继续加载，则传入NO
        [searchView reloadData:NO];
    }
    else
    {
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果已全部加载，则传入YES
        [searchView reloadData:YES];
    }
}

#pragma mark -
#pragma mark - UITableViewDelegate

//某一行被选中,由ViewController来实现push详细页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.articles count] > indexPath.row) {
        ArticleItem *aArticle = [self.articles objectAtIndex:indexPath.row];
        SVWebViewController *viewController = [[SVWebViewController alloc] initWithHTMLString:aArticle URL:aArticle.articleURL];
        
        //NSLog(@"didSelectArticle:%@",aArticle.content);
        [self.navigationController pushViewController:viewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSString *article = [(ArticleItem *)[self.articles objectAtIndex:indexPath.row] description];
    //    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000);
    //    CGSize size = [article sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    return 53;//计算每一个cell的高度
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([articles count] == 0) {
        //  本方法是为了在数据为空时，让“下拉刷新”视图可直接显示，比较直观
        tableView.contentInset = UIEdgeInsetsMake(k_STATE_VIEW_HEIGHT, 0, 0, 0);
    }
    return MAX(10, [articles count]);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    SearchItemCell *cell = (SearchItemCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SearchItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Leave cells empty if there's no data yet
    if ([self.articles count] > 0) {
        // Set up the cell...
        if (indexPath.row+1 > [self.articles count]) {
            cell.nameLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"IconPlaceholder.png"];
            [cell.imageView setHidden:YES];
        }else {
            ArticleItem *aArticle = [self.articles objectAtIndex:indexPath.row];
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
    
    return cell;
}

#pragma mark -
#pragma mark searchbar Delegate
- (void)doSearch:(UISearchBar *)searchBar{
    //取消UISearchBar调用的键盘
    [searchBar resignFirstResponder];
    //[searchView setHidden:NO];
    
    [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
}

/*取消按钮*/
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //取消UISearchBar调用的键盘
    [searchBar resignFirstResponder];
    self.searchStr = @"";
    [searchBar setText:self.searchStr];
    //[searchView setHidden:YES];
    //[self.RootScrollView setContentOffset:CGPointMake((userSelectedChannelID-100)*320, 0) animated:YES];
}

/*键盘搜索按钮*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self doSearch:searchBar];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarShouldBeginEditing");
    searchBar.showsCancelButton = YES;
    //改变UISearchBar取消按钮字体
    for(id cc in [searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            //btn.buttonType = UIButtonTypeCustom;
            //btn.frame = CGRectMake(0, 0, 55, 30);
            [btn setTitle:@"取消" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn setTintColor:[UIColor colorWithRed:(35.0f/255.0f) green:(127.0f/255.0f) blue:(187.0f/255.0f) alpha:1.0f]];
            //[btn setBackgroundImage:[UIImage imageNamed:@"Cancel.png"] forState:UIControlStateNormal];
            //[btn setBackgroundImage:[UIImage imageNamed:@"Cancel-gray.png"] forState:UIControlStateHighlighted];
        }
    }
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarShouldEndEditing");
    searchBar.showsCancelButton = NO;
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarTextDidBeginEditing");
    //itunesAppnamesTableView.frame = CGRectMake(0, 40, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-40-20-44);
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarTextDidEndEditing");
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //NSLog(@"textDidChange:%@", searchText);
    self.searchStr = searchText;
}

- (void)getArticles {
    // start activity indicator
    //[[self indicator] startAnimating];
    //[self.pullToRefreshTableView setAlpha:0.5];
    //[pullToRefreshTableView setHidden:YES];
    [alerViewManager showMessage:@"正在加载数据" inView:self.view];
    
    NSMutableArray *article = [NSMutableArray array];
    NSString *urlString =  [NSString stringWithFormat:@"http://dt.appgame.com/feed?paged=%d&s=%@", start, self.searchStr];
    if (self.searchStr == nil) {
        urlString = [NSString stringWithFormat:@"http://dt.appgame.com/feed?paged=%d", start];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
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
            if (start < 2) {
                [self.articles removeAllObjects];
                
                self.articles = article;
                
                [alerViewManager dismissMessageView:self.view];
            }
            else
            {
                for (ArticleItem *articleItem in article) {
                    [self.articles addObject:articleItem];
                }
                [alerViewManager dismissMessageView:self.view];
            }
        }
        else
        {
            [alerViewManager dismissMessageView:self.view];
            //[alerViewManager showOnlyMessage:@"暂无更多数据" inView:self.view];
        }
        //self.articles = [[articles reverseObjectEnumerator] allObjects];
        
        // reload the table
        [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
        
    } failure:^(NSError *error) {
        
        //something went wrong
        NSLog(@"Failure: %@", error);
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

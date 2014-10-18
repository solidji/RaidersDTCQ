//
//  NewsViewController.m
//  RaidersDtcq
//
//  Created by 计 炜 on 14-10-16.
//  Copyright (c) 2014年 计 炜. All rights reserved.
//

#import "NewsViewController.h"

#import "Globle.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"

#import "ArticleItem.h"
#import "ArticleItemCell.h"
#import "HomeViewCell.h"

#import "SVWebViewController.h"
#import "DetailViewController.h"
#import "MJRefresh.h"
#import "AlerViewManager.h"

@interface NewsViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *newsTableView;
@property (strong, nonatomic) NSMutableArray *dataList;

@property (nonatomic, copy) NSString *webURL;
@property (nonatomic, retain) AlerViewManager *alerViewManager;

@property (nonatomic, strong) MJRefreshHeaderView *header;
@property (nonatomic, assign) NSInteger start,receiveMember;
@property (nonatomic, assign) BOOL ifNeedFristLoading;
@property (nonatomic, assign) BOOL updating;//正在更新中,不要重复了

- (void)getArticles;

@end

@implementation NewsViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        self.title = @"资讯";
//        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"活动"
//                                                        image:[UIImage imageNamed:@"活动"]
//                                                selectedImage:[UIImage imageNamed:@"活动按下"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setDefaultLeftBarButtonItem];
    
    _alerViewManager = [[AlerViewManager alloc] init];
    _ifNeedFristLoading = YES;
    
    _dataList = [[NSMutableArray alloc] init];
    _start = _receiveMember = 0;
    _updating = NO;
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(clickGoBackButton:)];
    swipeGesture.delegate = self;
    [swipeGesture setDirection:(UISwipeGestureRecognizerDirectionRight)];
    swipeGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:swipeGesture];
    
    __unsafe_unretained NewsViewController *vc = self;
    //添加下拉刷新
    _header = [MJRefreshHeaderView header];
    _header.scrollView = self.newsTableView;
    
    _header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        
        [vc.dataList removeAllObjects];
        vc->_start = 0;
        [vc.newsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
        [vc performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
    };
    _header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        LOG(@"%@----刷新完毕", refreshView.class);
    };
    _header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                LOG(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                LOG(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                LOG(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
    
    [_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    LOG(@"MJCollectionViewController--dealloc---");
    [_header free];
    //[_footer free];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark - UITableViewDelegate

//某一行被选中,由ViewController来实现push详细页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *vc = [[DetailViewController alloc] initWithTitle:self.title];
    vc.appData = self.dataList;
    vc.startIndex = indexPath.row;
    
    //NSLog(@"didSelectArticle:%@",aArticle.content);
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//反选
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 88.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HomeViewCell";

    HomeViewCell *cell = (HomeViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HomeViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    int nodeCount = [self.dataList count];
    if (nodeCount > 0)
    {
        // Set up the cell...
        ArticleItem *aArticle = [self.dataList objectAtIndex:indexPath.row];
        cell.descriptLabel.text = aArticle.description;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        cell.creatorLabel.text = [NSString stringWithFormat:@"发表于 %@ 由 %@",[dateFormatter stringFromDate:aArticle.pubDate],aArticle.creator];
        
        cell.articleLabel.text = aArticle.title;
        cell.imageView.frame = CGRectMake(12.0f, 12.0f, 105.0f, 65.0f);
        [cell.imageView setImageWithURL:aArticle.articleIconURL
                       placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
        
        CGSize constraint = CGSizeMake(320.0f-105.0f-36.0f, 20000);
        CGSize size = [cell.articleLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        [cell.articleLabel setFrame:CGRectMake(105.0f+24.0f, 12.0f, 320.0f-105.0f-36.0f, MIN(size.height, 42.0f))];
        //NSLog(@"cellSize:%@ %f %f",aArticle.title,size.height,size.width);
        [cell.descriptLabel setFrame:CGRectMake(105.0f+24.0f, 12.0f+MIN(size.height, 55.0f), 320.0f-105.0f-36.0f, (55.0f-size.height))];
        if (size.height>50.0f) {
            [cell.descriptLabel setHidden:YES];
        }
        [cell.creatorLabel setFrame:CGRectMake(105.0f+24.0f, 12.0f+55.0f, 320.0f-105.0f-36.0f, 15.0f)];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //自动载入更新数据,每次载入20条信息，在滚动到倒数第3条以内时，加载更多信息
    if (self.dataList.count - indexPath.row < 3 && !_updating && _receiveMember >= 20) {
        _updating = YES;
        NSLog(@"滚到最后了");
        
        _start = [_dataList count]/20 + 1;
        
        [self performSelectorOnMainThread:@selector(getArticles) withObject:nil waitUntilDone:NO];
        // update方法获取到结果后，设置updating为NO
    }
}

- (void)getArticles {
    // start activity indicator
    [_alerViewManager showMessage:@"正在加载数据" inView:self.view];

    NSString *starString =  [NSString stringWithFormat:@"%d", _start];
    AFHTTPClient *jsonapiClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://www.appgame.com/"]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"get_posts", @"json",
                                @"20", @"count",
                                @"attachments", @"exclude",
                                starString, @"page",
                                nil];
    
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
                           LOG(@"获取文章json异常");
                       }else {
                           if ([[responseDictionary objectForKey:@"count"] integerValue] > 0) {
                               NSMutableArray *_comments = [NSMutableArray array];
                               // parse into array of comments
                               NSArray *commentsArray = [responseDictionary objectForKey:@"posts"];
                               
                               // setting date format
                               NSDateFormatter *df = [[NSDateFormatter alloc] init];
                               NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                               [df setLocale:locale];
                               [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                               
                               // traverse the array, getting data for comments
                               for (NSDictionary *commentDictionary in commentsArray) {
                                   // for every comment, wrap them with IADisqusComment
                                   ArticleItem *aComment = [[ArticleItem alloc] init];
                                   id urlStr = [commentDictionary objectForKey:@"thumbnail"];
                                   if (!urlStr)
                                       urlStr = @"";
                                   else if (![urlStr isKindOfClass: [NSString class]])
                                       urlStr = [urlStr description];
                                   aComment.articleIconURL = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                   aComment.pubDate = [df dateFromString:[[commentDictionary objectForKey:@"date"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                                   
                                   //aComment.description = [commentDictionary objectForKey:@"excerpt"];
                                   aComment.description = [commentDictionary objectForKey:@"excerpt"];
                                   NSString *regEx_html = [commentDictionary objectForKey:@"excerpt"];
                                   NSError *error;
                                   //(.|\\s)*或([\\s\\S]*)可以匹配包括换行在内的任意字符
                                   //NSString *regEx_html = "<[^>]+>";
                                   NSRegularExpression *regexW3tc = [NSRegularExpression
                                                                     regularExpressionWithPattern:@"<[^>]+>"
                                                                     options:NSRegularExpressionCaseInsensitive
                                                                     error:&error];
                                   [regexW3tc enumerateMatchesInString:regEx_html
                                                               options:0
                                                                 range:NSMakeRange(0, regEx_html.length)
                                                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                                                aComment.description = [aComment.description stringByReplacingOccurrencesOfString:[regEx_html substringWithRange:result.range] withString:@""];
                                                            }];
                                   
                                   aComment.description = [aComment.description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                   
                                   if (aComment.description != nil) {
                                       aComment.description = [aComment.description stringByReplacingOccurrencesOfString:@"&#038;" withString:@"&"];
                                       aComment.description = [aComment.description stringByReplacingOccurrencesOfString:@"继续阅读" withString:@""];
                                       aComment.description = [aComment.description stringByReplacingOccurrencesOfString:@"&rarr;" withString:@""];
                                   }
                                   aComment.title = [commentDictionary objectForKey:@"title"];
                                   if (aComment.title != nil) {
                                       aComment.title = [aComment.title stringByReplacingOccurrencesOfString:@"&#038;" withString:@"&"];
                                       aComment.title = [aComment.title stringByReplacingOccurrencesOfString:@"继续阅读" withString:@""];
                                       aComment.title = [aComment.title stringByReplacingOccurrencesOfString:@"&rarr;" withString:@""];
                                       aComment.title = [aComment.title stringByReplacingOccurrencesOfString:@"&#8217;" withString:@"'"];
                                       aComment.title = [aComment.title stringByReplacingOccurrencesOfString:@"&#8211;" withString:@"–"];
                                       aComment.title = [aComment.title stringByReplacingOccurrencesOfString:@"&#8230;" withString:@"…"];
                                       aComment.title = [aComment.title stringByReplacingOccurrencesOfString:@"&#8482;" withString:@"™"];
                                   }
                                   
                                   aComment.content = [commentDictionary objectForKey:@"content"];
                                   aComment.articleURL = [NSURL URLWithString:[[commentDictionary objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                   aComment.creator = [[commentDictionary objectForKey:@"author"] objectForKey:@"nickname"];
                                   
                                   if (aComment.content != nil) {
                                       NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"appgame" ofType:@"html"];
                                       NSString *htmlString = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
                                       NSString *contentHtml = @"";
                                       NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                       [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
                                       contentHtml = [contentHtml stringByAppendingFormat:htmlString,
                                                      aComment.title, aComment.creator, [dateFormatter stringFromDate:aComment.pubDate]];
                                       contentHtml = [contentHtml stringByReplacingOccurrencesOfString:@"<!--content-->" withString:aComment.content];
                                       aComment.content = contentHtml;
                                   }
                                   // add the comment to the mutable array
                                   [_comments addObject:aComment];
                               }
                               
                               //[alerViewManager showMessage:@"正在加载数据" inView:self.view];
                               for (ArticleItem *commentItem in _comments) {
                                   [self.dataList addObject:commentItem];
                               }
                               _receiveMember = [[responseDictionary objectForKey:@"count"] integerValue];
                               [self.newsTableView reloadData];
                               //[self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:YES];
                               }
                           //到这里就是0条数据
                       }

                        [_header endRefreshing];
                        _updating = NO;
                       //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                       [_alerViewManager dismissMessageView:self.view];
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       // pass error to the block
                       LOG(@"获取文章json失败:%@",error);
                       [_header endRefreshing];
                       _updating = NO;
                       [_alerViewManager dismissMessageView:self.view];
                   }];

}

@end

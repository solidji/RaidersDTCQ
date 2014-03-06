//
//  VideoViewController.m
//  RaidersDOTA
//
//  Created by 计 炜 on 13-7-19.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "VideoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"

#import "ArticleItem.h"
#import "ArticleItemCell.h"
#import "HomeViewCell.h"
#import "Globle.h"
#import "GlobalConfigure.h"

@interface VideoViewController ()
- (void)getComments;
- (void)playVideo;
-(NSArray *)videosFromHTMLString:(NSString *)htmlstr;
- (void)goPopClicked:(UIBarButtonItem *)sender;
@property (nonatomic, strong) VideoPlayerKit *videoPlayerViewController;
@end

@implementation VideoViewController

@synthesize comments,pullToRefreshTableView;

#pragma mark - View lifecycle
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
    
    alerViewManager = [[AlerViewManager alloc] init];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = CGRectMake(0, 0, [Globle shareInstance].globleWidth, [Globle shareInstance].globleHeight);
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background-2.png"]];
    UIImage *image = [UIImage imageNamed:@"Background.png"];
    if (IPhone5) {
        image = [UIImage imageNamed:@"Backgroundh.png"];
    }
    UIImageView *bg = [[UIImageView alloc] initWithImage:image];
    bg.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    bg.alpha = 0.5f;
    [self.view addSubview:bg];
    comments = [[NSMutableArray alloc] init];
    start = 0;
    receiveMember = 0;
    
    pullToRefreshTableView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) withType: withStateViews];//[[UIScreen mainScreen] bounds].size.height-20
    
    [self.pullToRefreshTableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    pullToRefreshTableView.delegate = self;
    pullToRefreshTableView.dataSource = self;
    pullToRefreshTableView.allowsSelection = YES;
    pullToRefreshTableView.backgroundColor = [UIColor clearColor];
    pullToRefreshTableView.backgroundColor = [UIColor colorWithRed:211.0f/255.0f green:214.0f/255.0f blue:219.0f/255.0f alpha:0.7f];
    pullToRefreshTableView.separatorStyle = UITableViewCellSeparatorStyleNone;//选中时cell样式
    pullToRefreshTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [pullToRefreshTableView setHidden:NO];
    //pullToRefreshTableView.alpha = 0.7f;
    [self.view addSubview:pullToRefreshTableView];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(goPopClicked:)];
    swipeGesture.delegate = self;
    [swipeGesture setDirection:(UISwipeGestureRecognizerDirectionRight)];
    swipeGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:swipeGesture];
    
    // get array of articles
    [self performSelectorInBackground:@selector(getComments) withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        //IOS5
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top.png"] forBarMetrics:UIBarMetricsDefault];
        //self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Class Methods
- (void)goPopClicked:(UIBarButtonItem *)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

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

#pragma mark -
#pragma mark - Table View control

- (void)updateThread:(NSString *)returnKey{
    @autoreleasepool {
        sleep(2);
        switch ([returnKey intValue]) {
            case k_RETURN_REFRESH:
            {
                [comments removeAllObjects];
                start = 0;
                [self performSelectorOnMainThread:@selector(getComments) withObject:nil waitUntilDone:NO];
                break;
            }
            case k_RETURN_LOADMORE:
            {
                start = [self.comments count]/20 + 1;
                
                [self performSelectorOnMainThread:@selector(getComments) withObject:nil waitUntilDone:NO];
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
        //if (hasNext)
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


#pragma mark - retrieve images from html string using regexp (private methode)

-(NSArray *)videosFromHTMLString:(NSString *)htmlstr
{
    NSMutableArray *videosURLStringArray = [[NSMutableArray alloc] init];
    
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"(https?)\\S*m3u8"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:htmlstr
                            options:0
                              range:NSMakeRange(0, htmlstr.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             [videosURLStringArray addObject:[htmlstr substringWithRange:result.range]];
                         }];
    
    return [NSArray arrayWithArray:videosURLStringArray];
}


-(NSArray *)videosFromHTMLStringQQ:(NSString *)htmlstr
{
    NSMutableArray *videosURLStringArray = [[NSMutableArray alloc] init];
    
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"vid=\\w+&"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:htmlstr
                            options:0
                              range:NSMakeRange(0, htmlstr.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             [videosURLStringArray addObject:[htmlstr substringWithRange:result.range]];
                         }];
    
    return [NSArray arrayWithArray:videosURLStringArray];
}

-(NSArray *)videosFromHTMLStringQQPic:(NSString *)htmlstr
{
    NSMutableArray *videosURLStringArray = [[NSMutableArray alloc] init];
    
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"pic=(https?)\\S*(png|jpg|jpeg|gif)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:htmlstr
                            options:0
                              range:NSMakeRange(0, htmlstr.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             [videosURLStringArray addObject:[htmlstr substringWithRange:result.range]];
                         }];
    
    return [NSArray arrayWithArray:videosURLStringArray];
}

- (void)playVideo
{   
    NSURL *url = [NSURL URLWithString:@"http://v.youku.com/player/getRealM3U8/vid/XNTYzNTk2Nzg4/type//video.m3u8"];
    
    
    if (!self.videoPlayerViewController) {
        self.videoPlayerViewController = [VideoPlayerKit videoPlayerWithContainingViewController:self optionalTopView:nil hideTopViewWithControls:YES];
        // Need to set edge inset if top view is inserted
        //[self.videoPlayerViewController setControlsEdgeInsets:UIEdgeInsetsMake(self.topView.frame.size.height, 0, 0, 0)];
        self.videoPlayerViewController.delegate = self;
        self.videoPlayerViewController.allowPortraitFullscreen = YES;
    }
    //[self.videoPlayerViewController.view setFrame:CGRectMake(0, 0, 50, 50)];
    [self.view addSubview:self.videoPlayerViewController.view];
    
    [self.videoPlayerViewController playVideoWithTitle:@"" URL:url videoID:nil shareURL:nil isStreaming:NO playInFullScreen:YES];
}

#pragma mark -
#pragma mark - UITableViewDelegate

//某一行被选中,由ViewController来实现push详细页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    DetailViewController *viewController = [[DetailViewController alloc] initWithTitle:self.title];
//    viewController.appData = self.comments;
//    viewController.startIndex = indexPath.row;
//    
//    //NSLog(@"didSelectArticle:%@",aArticle.content);
//    [self.navigationController pushViewController:viewController animated:YES];
    
    ArticleItem *aComment = [self.comments objectAtIndex:indexPath.row];
    NSArray *videosURLStringArray = [[NSArray alloc] init];
    
    videosURLStringArray = [self videosFromHTMLStringQQ:aComment.content];
    
    if ([videosURLStringArray count] >0) {
        
        NSString * vidtmp = videosURLStringArray[0];
        NSRange range = NSMakeRange(4, vidtmp.length-5);
        NSString * vid = [vidtmp substringWithRange:range];
        NSLog(@"vid is:%@",vid);
        
        AFHTTPClient *jsonapiClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://vv.video.qq.com/"]];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"json", @"otype",
                                    vid, @"vid",
                                    nil];
        
        [jsonapiClient getPath:@"geturl"
                    parameters:parameters
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           
                           __block NSString *jsonString = operation.responseString;
                           
                           NSError *error;
                           //(.|\\s)*或([\\s\\S]*)可以匹配包括换行在内的任意字符
                           NSRegularExpression *regexW3tc = [NSRegularExpression
                                                             regularExpressionWithPattern:@"QZOutputJson="
                                                             options:NSRegularExpressionCaseInsensitive
                                                             error:&error];
                           [regexW3tc enumerateMatchesInString:jsonString
                                                       options:0
                                                         range:NSMakeRange(0, jsonString.length)
                                                    usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                                        jsonString = [jsonString stringByReplacingOccurrencesOfString:[jsonString substringWithRange:result.range] withString:@""];
                                                    }];
                           
                           jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                           jsonString = [jsonString stringByReplacingOccurrencesOfString:@";" withString:@""];
                           
                           NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                           // fetch the json response to a dictionary
                           NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                           // pass it to the block
                           //ArticleItem *aArticle = [[ArticleItem alloc] init];
                           
                           NSArray *commentsArray = [[responseDictionary objectForKey:@"vd"] objectForKey:@"vi"];
                           
                           aComment.articleURL = [NSURL URLWithString:[commentsArray[0] objectForKey:@"url"]];
                           
                           if (!self.videoPlayerViewController) {
                               self.videoPlayerViewController = [VideoPlayerKit videoPlayerWithContainingViewController:self optionalTopView:nil hideTopViewWithControls:YES];
                               // Need to set edge inset if top view is inserted
                               //[self.videoPlayerViewController setControlsEdgeInsets:UIEdgeInsetsMake(self.topView.frame.size.height, 0, 0, 0)];
                               self.videoPlayerViewController.delegate = self;
                               self.videoPlayerViewController.allowPortraitFullscreen = YES;
                           }
                           //[self.videoPlayerViewController.view setFrame:CGRectMake(0, 0, 50, 50)];
                           [self.view addSubview:self.videoPlayerViewController.view];
                           
                           [self.videoPlayerViewController playVideoWithTitle:@"" URL:aComment.articleURL videoID:nil shareURL:nil isStreaming:NO playInFullScreen:YES];
                           
                           [tableView deselectRowAtIndexPath:indexPath animated:YES];//反选
                       }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           // pass error to the block
                           NSLog(@"获取视频json失败:%@",error);
                       }];
    }

    //[self videosFromHTMLStringQQPic:aComment.content];
    //[self playVideo];
    
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 88.0f;
    
//    ArticleItem *comment = (ArticleItem *)[self.comments objectAtIndex:indexPath.row];
//    CGSize constraint = CGSizeMake(290.0f-16.0, 20000);
//    CGSize size = [comment.title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
//    
//    return MAX(size.height, 20.0f) + 40.0f;//计算每一个cell的高度
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([comments count] == 0) {
        //  本方法是为了在数据为空时，让“下拉刷新”视图可直接显示，比较直观
        tableView.contentInset = UIEdgeInsetsMake(k_STATE_VIEW_HEIGHT, 0, 0, 0);
    }
    return [comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    HomeViewCell *cell = (HomeViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HomeViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    int nodeCount = [self.comments count];
    if (nodeCount > 0)
    {
        // Set up the cell...
        ArticleItem *aArticle = [self.comments objectAtIndex:indexPath.row];
        cell.descriptLabel.text = @"视频";
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        cell.creatorLabel.text = [NSString stringWithFormat:@"发表于 %@ 由 %@",[dateFormatter stringFromDate:aArticle.pubDate],aArticle.creator];
        
        cell.articleLabel.text = aArticle.title;
        
        NSArray *videosPicStringArray = [[NSArray alloc] init];
        
        NSURL *urlPic = [NSURL URLWithString:@"http://www.appgame.com/wp-content/uploads/2013/08/hello-hero.jpg"];
        videosPicStringArray = [self videosFromHTMLStringQQPic:aArticle.content];
        if ([videosPicStringArray count]>0) {
            urlPic = [NSURL URLWithString:[videosPicStringArray[0] substringFromIndex:4]];
        }
        aArticle.articleIconURL = urlPic;
        
        cell.imageView.frame = CGRectMake(12.0f, 12.0f, 100.0f, 76.0f);
        [cell.imageView setImageWithURL:aArticle.articleIconURL
                       placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
        
        CGSize constraint = CGSizeMake(320.0f-100.0f-36.0f, 20000);
        CGSize size = [cell.articleLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        [cell.articleLabel setFrame:CGRectMake(100.0f+24.0f, 12.0f, 320.0f-100.0f-36.0f, MIN(size.height, 40.0f))];
        //NSLog(@"cellSize:%@ %f %f",aArticle.title,size.height,size.width);
        [cell.descriptLabel setFrame:CGRectMake(100.0f+24.0f, 12.0f+40.0f, 320.0f-100.0f-36.0f, 20)];
        cell.descriptLabel.textColor = [UIColor orangeColor];
        //if (size.height>50.0f) {
        //[cell.descriptLabel setHidden:YES];
        //}
        [cell.creatorLabel setFrame:CGRectMake(100.0f+24.0f, 12.0f+60.0f, 320.0f-100.0f-36.0f, 16.0f)];
    }
    
    return cell;    return cell;
}

- (void)getComments {
    
    [alerViewManager showMessage:@"正在加载数据" inView:self.view];
    
    NSString *starString =  [NSString stringWithFormat:@"%ld", (long)start];
    AFHTTPClient *jsonapiClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://dtcq.appgame.com/"]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"get_category_posts", @"json",
                                @"re-men-shi-pin", @"slug",
                                @"20", @"count",
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
                           NSLog(@"获取视频json异常");
                       }else {
                           receiveMember = [[responseDictionary objectForKey:@"count"] integerValue];
                           if (receiveMember > 0) {
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
                                   
                                   //aComment.articleIconURL = [NSURL URLWithString:[[commentDictionary objectForKey:@"thumbnail"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                   aComment.pubDate = [df dateFromString:[[commentDictionary objectForKey:@"date"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                                   
                                   aComment.description = [commentDictionary objectForKey:@"excerpt"];
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
                               
                               for (ArticleItem *commentItem in _comments) {
                                   [self.comments addObject:commentItem];
                               }
                               //self.comments = [NSMutableArray arrayWithArray:_comments];
                               
                               [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:YES];
                           }
                           //到这里就是0条数据
                       }
                       [alerViewManager dismissMessageView:self.view];
                       if ([pullToRefreshTableView isHidden])
                       {
                           [pullToRefreshTableView setHidden:NO];
                       }
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       // pass error to the block
                       NSLog(@"获取视频json失败:%@",error);
                       [alerViewManager dismissMessageView:self.view];
                   }];
}
@end

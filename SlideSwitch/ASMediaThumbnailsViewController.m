//
//  ASMediaThumbnailsViewController.m
//  RaidersDOTA
//
//  Created by 计 炜 on 13-7-11.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "ASMediaThumbnailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"
#import "Globle.h"
#import "PhotoCell.h"
#import "ArticleItem.h"
#import "GlobalConfigure.h"

static CGFloat const kMaxAngle = 0.1;
static CGFloat const kMaxOffset = 20;

@interface ASMediaThumbnailsViewController ()
- (void)getComments;
-(NSArray *)imagesFromHTMLString:(NSString *)htmlstr;
@end

@implementation ASMediaThumbnailsViewController
@synthesize imageViews,photoFocusManager,contentView,comments,pullToRefreshTableView,scrollView;

+ (float)randomFloatBetween:(float)smallNumber andMax:(float)bigNumber
{
    float diff = bigNumber - smallNumber;
    
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

- (void)addSomeRandomTransformOnThumbnailViews:views
{
    for(UIView *view in views)
    {
        CGFloat angle;
        NSInteger offsetX;
        NSInteger offsetY;
        
        angle = [ASMediaThumbnailsViewController randomFloatBetween:-kMaxAngle andMax:kMaxAngle];
        offsetX = (NSInteger)[ASMediaThumbnailsViewController randomFloatBetween:-kMaxOffset andMax:kMaxOffset];
        offsetY = (NSInteger)[ASMediaThumbnailsViewController randomFloatBetween:-kMaxOffset andMax:kMaxOffset];
        view.transform = CGAffineTransformMakeRotation(angle);
        view.center = CGPointMake(view.center.x + offsetX, view.center.y + offsetY);
        
        // This is going to avoid crispy edges.
        view.layer.shouldRasterize = YES;
        view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.photoFocusManager = [[ASMediaFocusManager alloc] init];
    self.photoFocusManager.delegate = self;
    self.imageViews = [[NSMutableArray alloc] init];
    
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
    
//    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    scrollView.delegate = self;
//    [self.view addSubview:scrollView];
//    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    [self.view addSubview:contentView];
//    
//    if(self.scrollView)
//    {
//        self.scrollView.contentSize = self.contentView.bounds.size;
//    }
    alerViewManager = [[AlerViewManager alloc] init];
    comments = [[NSMutableArray alloc] init];
    start = 0;
    receiveMember = 0;
    
    pullToRefreshTableView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) withType: withStateViews];
    
    [self.pullToRefreshTableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    pullToRefreshTableView.delegate = self;
    pullToRefreshTableView.dataSource = self;
    pullToRefreshTableView.allowsSelection = NO;
    pullToRefreshTableView.backgroundColor = [UIColor clearColor];
    //pullToRefreshTableView.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:244.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
    //tableView.backgroundColor = [UIColor colorWithRed:19.0f/255 green:47.0f/255 blue:69.0f/255 alpha:1.0];
    pullToRefreshTableView.backgroundColor = [UIColor colorWithRed:211.0f/255.0f green:214.0f/255.0f blue:219.0f/255.0f alpha:0.7f];
    pullToRefreshTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    pullToRefreshTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //tableView.alpha = 0.8f;
    
    [self.view addSubview:pullToRefreshTableView];
    
    // Tells which views need to be focusable. You can put your image views in an array and give it to the focus manager.
//    UIImageView * imgItem = [[UIImageView alloc] init];
//    [imgItem setImageWithURL:[NSURL URLWithString:@"http://dt.appgame.com/wp-content/uploads/sites/14/2013/07/612-612-%E8%AF%B7%E5%8F%AB%E6%88%91%E9%9D%92%E8%9B%99%E7%8E%8B%E5%AD%90%E2%80%94%E6%88%91%E6%98%AF%E5%B0%8F%E6%AD%AA.png"]
//                   placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
//    
//    
//    [imageViews addObject:imgItem];
//    [imageViews addObject:imgItem];
//    [imageViews addObject:imgItem];
//    [imageViews addObject:imgItem];
//    
//    [self.mediaFocusManager installOnViews:self.imageViews];
//    
//    [self addSomeRandomTransformOnThumbnailViews:];
    
    [self performSelectorInBackground:@selector(getComments) withObject:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - ASMediaFocusDelegate
// Returns an image that represents the media view. This image is used in the focusing animation view.
// It is usually a small image.
- (UIImage *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager imageForView:(UIView *)view
{
    return ((UIImageView *)view).image;
}

// Returns the final focused frame for this media view. This frame is usually a full screen frame.
- (CGRect)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager finalFrameforView:(UIView *)view
{
    return self.parentViewController.view.bounds;
}

// Returns the view controller in which the focus controller is going to be added.
// This can be any view controller, full screen or not.
- (UIViewController *)parentViewControllerForMediaFocusManager:(ASMediaFocusManager *)mediaFocusManager
{
    return self.parentViewController;
}

// Returns an URL where the image is stored. This URL is used to create an image at full screen. The URL may be local (file://) or distant (http://).
- (NSURL *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager mediaURLForView:(UIView *)view
{
    NSURL *url;
    if ([self.imageViews count] >= view.tag) {
        url = [self.imageViews objectAtIndex:(view.tag-1)];
    }else {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"IconPlaceholder" ofType:@"png"];
        url = [NSURL fileURLWithPath:path];
    }
    return url;
}

// Returns the title for this media view. Return nil if you don't want any title to appear.
- (NSString *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager titleForView:(UIView *)view;
{
    NSString *title;
    
    title = [NSString stringWithFormat:@"Image %@", [self mediaFocusManager:mediaFocusManager mediaURLForView:view].lastPathComponent];
    
    return title;//@"Of course, you can zoom in and out on the image.";
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    NSString *path;
//    UIImage *image;
    
    if(cell == nil)
    {
        cell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [self.photoFocusManager installOnView:cell.imageView];
    }
    int nodeCount = [self.comments count];
    if (nodeCount>0) {
        ArticleItem *aComment = [self.comments objectAtIndex:indexPath.row];
        cell.articleLabel.text = aComment.title;
        
        NSArray* picArray = [self imagesFromHTMLString:aComment.content];
        if (picArray.count >= 3) {
            
            //NSMutableString *iconURL = [NSMutableString stringWithString:[picArray objectAtIndex:0]];
            
            //中文URL编码
            //articleItem.iconURL = [NSURL URLWithString:[iconURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
            [cell.imageView setImageWithURL:[NSURL URLWithString:[[NSMutableString stringWithString:[picArray objectAtIndex:0]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                          placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
            
            [cell.imageView2 setImageWithURL:[NSURL URLWithString:[[NSMutableString stringWithString:[picArray objectAtIndex:1]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                           placeholderImage:nil];
            
            [cell.imageView3 setImageWithURL:[NSURL URLWithString:[[NSMutableString stringWithString:[picArray objectAtIndex:2]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                           placeholderImage:nil];
            
            [self.photoFocusManager installOnViews:[NSArray arrayWithObjects:
                                                    cell.imageView,
                                                    cell.imageView2,
                                                    cell.imageView3
                                                    ,nil]];
//            [self addSomeRandomTransformOnThumbnailViews:[NSArray arrayWithObjects:
//                                                          cell.imageView,
//                                                          cell.imageView2,
//                                                          cell.imageView3
//                                                          ,nil]];
        }
        cell.imageView.tag = indexPath.row*3 + 1;
        cell.imageView2.tag = indexPath.row*3 + 2;
        cell.imageView3.tag = indexPath.row*3 + 3;
        
        cell.articleLabel.frame = CGRectMake(10, 0.0, 200, 30);

        cell.imageView.frame = CGRectMake(20, 28.0  , 74, 56);
        cell.imageView2.frame = CGRectMake(20+74+29, 28.0, 74, 56);
        cell.imageView3.frame = CGRectMake(20+74+74+58, 28.0, 74, 56);
    
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([comments count] == 0) {
        //  本方法是为了在数据为空时，让“下拉刷新”视图可直接显示，比较直观
        tableView.contentInset = UIEdgeInsetsMake(k_STATE_VIEW_HEIGHT, 0, 0, 0);
    }
    return [comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
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
                [imageViews removeAllObjects];
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

-(NSArray *)imagesFromHTMLString:(NSString *)htmlstr
{
    NSMutableArray *imagesURLStringArray = [[NSMutableArray alloc] init];
    
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"(https?)\\S*(png|jpg|jpeg|gif)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:htmlstr
                            options:0
                              range:NSMakeRange(0, htmlstr.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             [imagesURLStringArray addObject:[htmlstr substringWithRange:result.range]];
                         }];
    
    return [NSArray arrayWithArray:imagesURLStringArray];
}

- (void)getComments{
    
    [alerViewManager showMessage:@"正在加载数据" inView:self.view];
    
    AFHTTPClient *jsonapiClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://dt.appgame.com/"]];
    NSString *starString =  [NSString stringWithFormat:@"%ld", (long)start];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"get_category_posts", @"json",
                                @"fu-ben-tu-jian", @"slug",
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
                           NSLog(@"获取分类json异常:fbtj");
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
                                   aComment.title = [commentDictionary objectForKey:@"title"];
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
                                   
                                   //tag需要判断选取唯一一个app_xxx格式的,暂时先随便获取
                                   aComment.tag = nil;
                                   NSArray *tagsArray = [commentDictionary objectForKey:@"tags"];
                                   if ([tagsArray count]>0) {
                                       NSDictionary *tagDic = tagsArray[0];
                                       aComment.tag = [tagDic objectForKey:@"slug"];
                                   }
                                   
                                   //取附件里的第一张图,如果没有就尝试取缩略图
                                   aComment.firstPicURL = nil;
                                   aComment.firstPicURL = [NSURL URLWithString:[[commentDictionary valueForKey:@"thumbnail"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//                                   aComment.firstPicURL = nil;
//                                   NSArray *attachmentsArray = [commentDictionary objectForKey:@"attachments"];
//                                   if ([attachmentsArray count]>0) {
//                                       NSDictionary *attachmentDic = attachmentsArray[0];
//                                       aComment.firstPicURL = [NSURL URLWithString:[[[[attachmentDic objectForKey:@"images"] valueForKey:@"small-feature"] valueForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//                                   }else {
//                                       aComment.firstPicURL = [NSURL URLWithString:[[commentDictionary valueForKey:@"thumbnail"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//                                   }
                                   
                                   // add the comment to the mutable array
                                   [_comments addObject:aComment];
                               }
                               
                               for (ArticleItem *commentItem in _comments) {
                                   
                                   NSArray* picArray = [self imagesFromHTMLString:commentItem.content];
                                   if (picArray.count >= 3) {
                                       [self.comments addObject:commentItem];
                                       [self.imageViews addObject:[NSURL URLWithString:[[NSMutableString stringWithString:[picArray objectAtIndex:0]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                                       [self.imageViews addObject:[NSURL URLWithString:[[NSMutableString stringWithString:[picArray objectAtIndex:1]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                                       [self.imageViews addObject:[NSURL URLWithString:[[NSMutableString stringWithString:[picArray objectAtIndex:2]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                                   }
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
                       NSLog(@"获取副本json失败:%@",error);
                       [alerViewManager dismissMessageView:self.view];
                   }];
}

@end

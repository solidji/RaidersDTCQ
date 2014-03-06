//
//  HorizonViewController.m
//  RaidersDOTA
//
//  Created by 计 炜 on 13-7-9.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "HorizonViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"

#import "ArticleItem.h"
#import "SVWebViewController.h"
#import "DetailViewController.h"
#import "GlobalConfigure.h"
#import "Globle.h"
#import "pullToRefreshTableView.h"
#import "AlerViewManager.H"

@interface HorizonViewController ()
- (void)getComments:(NSString* )slug;
@end

@implementation HorizonViewController
@synthesize horizontalTableView,dataList1,dataList2,dataList3,dataList4;

- (id)initWithTitle:(NSString *)title
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
//        ListItem *item1 = [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"熊战士（紫）"];
//        ListItem *item2 = [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"骷髅王（蓝）"];
//        ListItem *item3 = [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"半人马酋长（紫）"];
//        ListItem *item4 = [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"人马酋长（绿）"];
//        ListItem *item5 = [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"熊猫酒仙（紫）"];
//        ListItem *item6 = [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"Game Pack"];
//        ListItem *item7 = [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"Movies"];
//        ListItem *item8 = [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"Forecast"];
//        ListItem *item9 = [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"Game Pack"];
//        ListItem *item10= [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"Movies"];
//        ListItem *item11= [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"News Reader"];
//        ListItem *item12= [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"Voice Recorder"];
//        ListItem *item13= [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"E-Trade"];
//        ListItem *item14= [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"Shopping"];
//        ListItem *item15= [[ListItem alloc] initWithFrame:CGRectZero image:[UIImage imageNamed:@"xzskp.jpg"] text:@"Weather"];
        
//        freeList = [[NSMutableArray alloc] initWithObjects: item1, item2, item3, item4, item5, nil];
//        paidList = [[NSMutableArray alloc] initWithObjects: item6, item7, item8, item9, item10, nil];
//        grossingList = [[NSMutableArray alloc] initWithObjects: item11, item12, item13, item14, item15, nil];
        dataList1 = [[NSMutableArray alloc] init];
        dataList2 = [[NSMutableArray alloc] init];
        dataList3 = [[NSMutableArray alloc] init];
        dataList4 = [[NSMutableArray alloc] init];
    }
    alerViewManager = [[AlerViewManager alloc] init];
    receiveMember = 0;
    self.title = title;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = CGRectMake(0, 0, [Globle shareInstance].globleWidth, [Globle shareInstance].globleHeight);
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background-2.png"]];
    UIImage *image = [UIImage imageNamed:@"Background.png"];
    if (IPhone5) {
        image = [UIImage imageNamed:@"Backgroundh.png"];
    }
    UIImageView *bg = [[UIImageView alloc] initWithImage:image];
    bg.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44-44);
    //bg.alpha = 0.5f;
    [self.view addSubview:bg];
    
    //horizontalTableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight) style:UITableViewStylePlain];
    receiveMember = 0;
    
    horizontalTableView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) withType: withStateViews];
    
    [self.horizontalTableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    horizontalTableView.delegate = self;
    horizontalTableView.dataSource = self;
    horizontalTableView.allowsSelection = NO;
    horizontalTableView.backgroundColor = [UIColor clearColor];
    //pullToRefreshTableView.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:244.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
    //tableView.backgroundColor = [UIColor colorWithRed:19.0f/255 green:47.0f/255 blue:69.0f/255 alpha:1.0];
    //horizontalTableView.backgroundColor = [UIColor colorWithRed:211.0f/255.0f green:214.0f/255.0f blue:219.0f/255.0f alpha:0.7f];
    //horizontalTableView.backgroundColor = [UIColor colorWithWhite:255.0f/255.0f alpha:0.7f];
    horizontalTableView.backgroundColor = [UIColor whiteColor];
    horizontalTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    horizontalTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //horizontalTableView.alpha = 0.8f;

    [self.view addSubview:horizontalTableView];
    //[self getComments:@"jing-ying"];
    NSInteger returnKey = k_RETURN_REFRESH;
    NSString * key = [NSString stringWithFormat:@"%d", returnKey];
    [NSThread detachNewThreadSelector:@selector(updateThread:) toTarget:self withObject:key];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - UITableViewDelegate

//某一行被选中,由ViewController来实现push详细页面
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    DetailViewController *viewController = [[DetailViewController alloc] initWithTitle:self.title];
//    if ([indexPath row] == 0) {
//        viewController.appData = self.liliangList;
//        viewController.startIndex = indexPath.row;
//        
//        //NSLog(@"didSelectArticle:%@",aArticle.content);
//        [self.navigationController pushViewController:viewController animated:YES];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];//反选
//    }
//    else if ([indexPath row] == 1) {
//        viewController.appData = self.minjieList;
//        viewController.startIndex = indexPath.row;
//        
//        //NSLog(@"didSelectArticle:%@",aArticle.content);
//        [self.navigationController pushViewController:viewController animated:YES];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];//反选
//    }
//    else if ([indexPath row] == 1) {
//        viewController.appData = self.zhiliList;
//        viewController.startIndex = indexPath.row;
//        
//        //NSLog(@"didSelectArticle:%@",aArticle.content);
//        [self.navigationController pushViewController:viewController animated:YES];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];//反选
//    }
//
//}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 139;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = [self.horizontalTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *title = @"";
    POHorizontalList *list;
    NSMutableArray *dataList = [[NSMutableArray alloc] init];
    
    if ([indexPath row] == 0) {
        title = @"力量型";
        for (ArticleItem *commentItem in dataList1) {
            UIImageView * imageview = [[UIImageView alloc] init];
            [imageview setImageWithURL:commentItem.firstPicURL
                      placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
            ListItem *listitem = [[ListItem alloc] initWithFrame:CGRectZero image:imageview text:commentItem.title];
            [dataList addObject:listitem];
        }
        list = [[POHorizontalList alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 139) title:title items:dataList];
    }
    else if ([indexPath row] == 1) {
        title = @"敏捷型";
        for (ArticleItem *commentItem in dataList2) {
            UIImageView * imageview = [[UIImageView alloc] init];
            [imageview setImageWithURL:commentItem.firstPicURL
                      placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
            ListItem *listitem = [[ListItem alloc] initWithFrame:CGRectZero image:imageview text:commentItem.title];
            [dataList addObject:listitem];
        }
        list = [[POHorizontalList alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 139) title:title items:dataList];
    }
    else if ([indexPath row] == 2) {
        title = @"智力型";
        for (ArticleItem *commentItem in dataList3) {
            UIImageView * imageview = [[UIImageView alloc] init];
            [imageview setImageWithURL:commentItem.firstPicURL
                      placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
            ListItem *listitem = [[ListItem alloc] initWithFrame:CGRectZero image:imageview text:commentItem.title];
            [dataList addObject:listitem];
        }
        list = [[POHorizontalList alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 139) title:title items:dataList];
    }
    else if ([indexPath row] == 3) {
        title = @"装备";
        for (ArticleItem *commentItem in dataList4) {
            UIImageView * imageview = [[UIImageView alloc] init];
            [imageview setImageWithURL:commentItem.firstPicURL
                      placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
            ListItem *listitem = [[ListItem alloc] initWithFrame:CGRectZero image:imageview text:commentItem.title];
            [dataList addObject:listitem];
        }
        list = [[POHorizontalList alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 139) title:title items:dataList];
    }
    
    [list setDelegate:self];
    [cell.contentView addSubview:list];
    
    return cell;
}

#pragma mark  POHorizontalListDelegate

- (void) didSelectItem:(ListItem *)item {
    NSLog(@"Horizontal List Item %@ selected", item.imageTitle);
    for (ArticleItem *commentItem in dataList1) {
        if([commentItem.title isEqualToString:item.imageTitle]) {
            DetailViewController *viewController = [[DetailViewController alloc] initWithTitle:self.title];
            viewController.appData = self.dataList1;
            viewController.startIndex = [dataList1 indexOfObject:commentItem];
            
            //NSLog(@"didSelectArticle:%@",aArticle.content);
            [self.navigationController pushViewController:viewController animated:YES];
            return;
        }
    }
    
    for (ArticleItem *commentItem in dataList2) {
        if([commentItem.title isEqualToString:item.imageTitle]) {
            DetailViewController *viewController = [[DetailViewController alloc] initWithTitle:self.title];
            viewController.appData = self.dataList2;
            viewController.startIndex = [dataList2 indexOfObject:commentItem];
            
            //NSLog(@"didSelectArticle:%@",aArticle.content);
            [self.navigationController pushViewController:viewController animated:YES];
            return;
        }
    }
    
    for (ArticleItem *commentItem in dataList3) {
        if([commentItem.title isEqualToString:item.imageTitle]) {
            DetailViewController *viewController = [[DetailViewController alloc] initWithTitle:self.title];
            viewController.appData = self.dataList3;
            viewController.startIndex = [dataList3 indexOfObject:commentItem];
            
            //NSLog(@"didSelectArticle:%@",aArticle.content);
            [self.navigationController pushViewController:viewController animated:YES];
            return;
        }
    }
    
    for (ArticleItem *commentItem in dataList4) {
        if([commentItem.title isEqualToString:item.imageTitle]) {
            DetailViewController *viewController = [[DetailViewController alloc] initWithTitle:self.title];
            viewController.appData = self.dataList4;
            viewController.startIndex = [dataList4 indexOfObject:commentItem];
            
            //NSLog(@"didSelectArticle:%@",aArticle.content);
            [self.navigationController pushViewController:viewController animated:YES];
            return;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [horizontalTableView tableViewDidDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSInteger returnKey = [horizontalTableView tableViewDidEndDragging];
    
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
                [dataList1 removeAllObjects];
                [dataList2 removeAllObjects];
                [dataList3 removeAllObjects];
                [dataList4 removeAllObjects];

                [self performSelectorOnMainThread:@selector(getComments:) withObject:@"li-liang" waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(getComments:) withObject:@"min-jie" waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(getComments:) withObject:@"zhi-li" waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(getComments:) withObject:@"zhuang-bei" waitUntilDone:NO];
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
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果已全部加载，则传入YES
        [horizontalTableView reloadData:YES];
}

- (void)getComments:(NSString* )slug {
    
    [alerViewManager showMessage:@"正在加载数据" inView:self.view];
    
    AFHTTPClient *jsonapiClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://dtcq.appgame.com/"]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"get_category_posts", @"json",
                                @"200", @"count",
                                @"attachments", @"exclude",
                                slug, @"slug",
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
                           NSLog(@"获取分类json异常:图鉴");
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
                                   id urlStr = [commentDictionary objectForKey:@"thumbnail"];
                                   if (!urlStr)
                                       urlStr = @"";
                                   else if (![urlStr isKindOfClass: [NSString class]])
                                       urlStr = [urlStr description];
                                   aComment.firstPicURL = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                   //aComment.firstPicURL = [NSURL URLWithString:[[commentDictionary valueForKey:@"thumbnail"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                   
//                                   if (aComment.firstPicURL != nil) {
//                                       NSArray *attachmentsArray = [commentDictionary objectForKey:@"attachments"];
//                                       if ([attachmentsArray count]>0) {
//                                           NSDictionary *attachmentDic = attachmentsArray[0];
//                                           aComment.firstPicURL = [NSURL URLWithString:[[[[attachmentDic objectForKey:@"images"] valueForKey:@"small-feature"] valueForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//                                       }
//                                   }
                                   
                                   // add the comment to the mutable array
                                   [_comments addObject:aComment];
                               }
                               
                               for (ArticleItem *commentItem in _comments) {
                                   //UIImageView * imageview = [[UIImageView alloc] init];
                                   //[imageview setImageWithURL:commentItem.firstPicURL
                                   //          placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
                                   //ListItem *listitem = [[ListItem alloc] initWithFrame:CGRectZero image:imageview text:commentItem.title];
                                   if ([slug isEqualToString:@"li-liang"]) {
                                       [self.dataList1 addObject:commentItem];
                                   }else if([slug isEqualToString:@"min-jie"]) {
                                       [self.dataList2 addObject:commentItem];
                                   }else if([slug isEqualToString:@"zhi-li"]) {
                                       [self.dataList3 addObject:commentItem];
                                   }else if([slug isEqualToString:@"zhuang-bei"]) {
                                       [self.dataList4 addObject:commentItem];
                                   }
                               }
                               //self.comments = [NSMutableArray arrayWithArray:_comments];
                               
                               [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                               //[horizontalTableView reloadData];
                           }
                           //到这里就是0条数据
                       }
                       [alerViewManager dismissMessageView:self.view];
                       if ([horizontalTableView isHidden])
                       {
                           [horizontalTableView setHidden:NO];
                       }
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       // pass error to the block
                       NSLog(@"获取分类json失败:%@",error);
                       [alerViewManager dismissMessageView:self.view];
                   }];
}
@end
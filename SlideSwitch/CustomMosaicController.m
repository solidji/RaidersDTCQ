//
//  CustomMosaicDatasource.m
//  RaidersDOTA
//
//  Created by 计 炜 on 13-7-12.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "CustomMosaicController.h"
#import "MosaicData.h"
#import "MosaicDataView.h"
#import "GlobalConfigure.h"
#import "Globle.h"
#import "MosaicData.h"

#import "UIImageView+AFNetworking.h"
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"
#import "DetailViewController.h"
#import "SVWebViewController.h"
#import "ArticleItem.h"
#import "VideoViewController.h"
#import "HMSideMenu.h"

@implementation CustomMosaicController
@synthesize mosaicView,elements,comments;


#pragma mark - Public
- (id)initWithTitle:(NSString *)title withFrame:(CGRect)frame
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        elements = [[NSMutableArray alloc] init];
        comments = [[NSMutableArray alloc] init];
        alerViewManager = [[AlerViewManager alloc] init];
        
//        NSMutableDictionary *aModuleDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//         @"612-612-3.png", @"imageFilename",
//         @"4", @"size",
//         @"1", @"title",
//         nil];
//        MosaicData *aMosaicModule = [[MosaicData alloc] initWithDictionary:aModuleDict];
//        
//        [elements addObject:aMosaicModule];
//        
//        aModuleDict = [@{@"imageFilename" : @"Forum-blue@2x.png",
//                         @"size" : @"1",
//                         @"title":@""} mutableCopy];
//        
//        [elements addObject:[[MosaicData alloc] initWithDictionary:aModuleDict]];
//
//        
////        [NSMutableDictionary dictionaryWithObjectsAndKeys:
////                        @"612-612-1.png", @"imageFilename",
////                        @"1", @"size",
////                        @"2", @"title",
////                        nil];
//        aModuleDict = [@{@"imageFilename" : @"612-612-1.png",
//                         @"size" : @"1",
//                         @"title":@"2"} mutableCopy];
//        
//        [elements addObject:[[MosaicData alloc] initWithDictionary:aModuleDict]];
//        
////        aModuleDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
////                       @"612-612-2.png", @"imageFilename",
////                       @"1", @"size",
////                       @"3", @"title",
////                       nil];
//        aModuleDict = [@{@"imageFilename" : @"612-612-6.png",
//                         @"size" : @"1",
//                         @"title":@"3"} mutableCopy];
//
//        [elements addObject:[[MosaicData alloc] initWithDictionary:aModuleDict]];
////        aModuleDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
////                       @"Set-up-blue@2x.png", @"imageFilename",
////                       @"1", @"size",
////                       @"setup", @"title",
////                       nil];
//        aModuleDict = [@{@"imageFilename" : @"video-blue@2x.png",
//                         @"size" : @"1",
//                         @"title":@""} mutableCopy];
//
//        [elements addObject:[[MosaicData alloc] initWithDictionary:aModuleDict]];
////        aModuleDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
////                       @"612-612-3.png", @"imageFilename",
////                       @"4", @"size",
////                       @"5", @"title",
////                       nil];
////        aModuleDict = [@{@"imageFilename" : @"612-612-3.png",
////                         @"size" : @"4",
////                         @"title":@"5"} mutableCopy];
////        [elements addObject:[[MosaicData alloc] initWithDictionary:aModuleDict]];
////        aModuleDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
////                       @"612-612-4.png", @"imageFilename",
////                       @"2", @"size",
////                       @"6", @"title",
////                       nil];
//        aModuleDict = [@{@"imageFilename" : @"612-612-4.png",
//                         @"size" : @"2",
//                         @"title":@"4"} mutableCopy];
//        [elements addObject:[[MosaicData alloc] initWithDictionary:aModuleDict]];
////        aModuleDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
////                       @"612-612-5.png", @"imageFilename",
////                       @"1", @"size",
////                       @"7", @"title",
////                       nil];
//        aModuleDict = [@{@"imageFilename" : @"612-612-5.png",
//                         @"size" : @"1",
//                         @"title":@"5"} mutableCopy];
//        [elements addObject:[[MosaicData alloc] initWithDictionary:aModuleDict]];
////        aModuleDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
////                       @"612-612-6.png", @"imageFilename",
////                       @"2", @"size",
////                       @"8", @"title",
////                       nil];
//        aModuleDict = [@{@"imageFilename" : @"612-612-2.png",
//                         @"size" : @"2",
//                         @"title":@"6"} mutableCopy];
//        [elements addObject:[[MosaicData alloc] initWithDictionary:aModuleDict]];
////        aModuleDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
////                       @"612-612-7.png", @"imageFilename",
////                       @"4", @"size",
////                       @"9", @"title",
////                       nil];
//        aModuleDict = [@{@"imageFilename" : @"612-612-7.png",
//                         @"size" : @"4",
//                         @"title":@"7"} mutableCopy];
//        [elements addObject:[[MosaicData alloc] initWithDictionary:aModuleDict]];
        
        
        //NSString *url = @"http://dt.appgame.com/wp-content/uploads/sites/14/2013/07/612-612-%E8%AF%B7%E5%8F%AB%E6%88%91%E9%9D%92%E8%9B%99%E7%8E%8B%E5%AD%90%E2%80%94%E6%88%91%E6%98%AF%E5%B0%8F%E6%AD%AA.png";
        //NSString *url = @"http://dt.appgame.com/wp-content/uploads/sites/14/2013/07/12013110575862550.gif";
//        NSString *url = @"Background@2x.png";
//        NSDictionary *cModuleDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                       url, @"imageFilename",
//                       @"1", @"size",
//                       @"2", @"title",
//                       nil];
//        MosaicData *cMosaicModule = [[MosaicData alloc] initWithDictionary:cModuleDict];
//        [elements addObject:cMosaicModule];
//        [elements addObject:cMosaicModule];
        
        //elements = [[NSMutableArray alloc] initWithObjects: item1, item1, item1, item1, item1, nil];
    }
    self.title = title;
    self.view.frame = frame;
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *image = [UIImage imageNamed:@"Background.png"];
    if (IPhone5) {
        image = [UIImage imageNamed:@"Backgroundh.png"];
    }
    UIImageView *bg = [[UIImageView alloc] initWithImage:image];
    bg.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    bg.alpha = 0.5f;
    [self.view addSubview:bg];
    //self.view.frame = CGRectMake(0, 0, [Globle shareInstance].globleWidth, [Globle shareInstance].globleHeight);
    
    mosaicView = [[MosaicView alloc] init];
    [mosaicView setFrame:self.view.frame];//CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    mosaicView.datasource = self;
    mosaicView.delegate = self;
    [self.view addSubview:mosaicView];
    //elements = [[NSMutableArray alloc] init];
    
    [self getComments];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MosaicViewDatasourceProtocol

-(NSArray *)mosaicElements{
    NSArray *retVal = elements;
    return retVal;
}

#pragma mark - MosaicViewDelegateProtocol

-(void)mosaicViewDidTap:(MosaicDataView *)aModule{
    NSLog(@"#DEBUG Tapped %@", aModule.module);

    DetailViewController *viewController = [[DetailViewController alloc] initWithTitle:self.title];
    viewController.appData = self.comments;

    switch ([elements indexOfObject:aModule.module]) {
        case 0:
            viewController.startIndex = [elements indexOfObject:aModule.module];
            break;
        case 1:
            //BBS
        {
            SVWebViewController *bbsViewController = [[SVWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://bbs.appgame.com/forum-120-1.html"]];
            
            //在第三页上添加刷新与后退按钮
            UIView *twitterItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [twitterItem setMenuActionWithBlock:^{
                [[bbsViewController mainWebView] goBack];
            }];
            UIImageView *twitterIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [twitterIcon setImage:[UIImage imageNamed:@"Retreat"]];
            [twitterItem addSubview:twitterIcon];
            
            UIView *emailItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [emailItem setMenuActionWithBlock:^{
                [[bbsViewController mainWebView] goForward];
            }];
            UIImageView *emailIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [emailIcon setImage:[UIImage imageNamed:@"Advance"]];
            [emailItem addSubview:emailIcon];
            
            
            UIView *browserItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [browserItem setMenuActionWithBlock:^{
                [[bbsViewController mainWebView] reload];
            }];
            UIImageView *browserIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [browserIcon setImage:[UIImage imageNamed:@"Refresh"]];
            [browserItem addSubview:browserIcon];
            
            HMSideMenu *sideMenu = [[HMSideMenu alloc] initWithItems:@[twitterItem, emailItem, browserItem]];
            [sideMenu setItemSpacing:5.0f];
            [[bbsViewController mainWebView] addSubview:sideMenu];
            [sideMenu open];
            
            [self.navigationController pushViewController:bbsViewController animated:YES];
            return;
        }
            break;
        case 2:
            viewController.startIndex = [elements indexOfObject:aModule.module]-1;
            break;
        case 3:
            viewController.startIndex = [elements indexOfObject:aModule.module]-1;
            break;
        case 4:
            //vedio
        {
            VideoViewController *videoPlayController = [[VideoViewController alloc] initWithTitle:@"精彩视频" withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
            
            [self.navigationController pushViewController:videoPlayController animated:YES];
            return;
        }
            break;
        default:
            viewController.startIndex = [elements indexOfObject:aModule.module]-2;
            break;
    }
    
    //NSLog(@"didSelectArticle:%@",aArticle.content);
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)mosaicViewDidDoubleTap:(MosaicDataView *)aModule{
    NSLog(@"#DEBUG Double Tapped %@", aModule.module);
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

- (void)refresh {
    [mosaicView refresh];
}

- (void)getComments {
    
    [alerViewManager showMessage:@"正在加载数据" inView:self.view];
    
    AFHTTPClient *jsonapiClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://dt.appgame.com/"]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"get_category_posts", @"json",
                                @"app-ke-hu-duan", @"slug",
                                @"7", @"count",
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
                           NSLog(@"获取瀑布流json异常");
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
                                   // add the comment to the mutable array
                                   [_comments addObject:aComment];
                               }
                               [elements removeAllObjects];
                               for (ArticleItem *commentItem in _comments) {
                                   [self.comments addObject:commentItem];
                                   
//                                   NSArray* picArray = [self imagesFromHTMLString:commentItem.content];
//                                   NSString *imageUrl = [[NSMutableString stringWithString:[picArray objectAtIndex:0]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                   
                                   NSMutableDictionary *aModuleDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                       commentItem.firstPicURL.absoluteString, @"imageFilename",
                                                                       @"1", @"size",
                                                                       @"", @"title",
                                                                       nil];
                                   if (elements.count == 0) {
                                       [aModuleDict setValue:@"4" forKey:@"size"];
                                   }else if (elements.count == 1) {
                                       [aModuleDict setValue:@"1" forKey:@"size"];
                                   }else if (elements.count == 2) {
                                       [aModuleDict setValue:@"1" forKey:@"size"];
                                   }else if (elements.count == 3) {
                                       [aModuleDict setValue:@"2" forKey:@"size"];
                                   }else if (elements.count == 4) {
                                       [aModuleDict setValue:@"1" forKey:@"size"];
                                   }else if (elements.count == 5) {
                                       [aModuleDict setValue:@"2" forKey:@"size"];
                                   }else if (elements.count == 6) {
                                       [aModuleDict setValue:@"4" forKey:@"size"];
                                   }
                                   MosaicData *aMosaicModule = [[MosaicData alloc] initWithDictionary:aModuleDict];
                                   [elements addObject:aMosaicModule];
                               }
                               
                               //插入论坛与视频的图
                               NSDictionary *bModuleDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   @"Forum-blue.png", @"imageFilename",
                                                                   @"1", @"size",
                                                                   @"", @"title",
                                                                   nil];

                               [elements insertObject:[[MosaicData alloc] initWithDictionary:bModuleDict] atIndex:1];
                               
                               NSDictionary *cModuleDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                            @"video-blue.png", @"imageFilename",
                                                            @"1", @"size",
                                                            @"", @"title",
                                                            nil];
                               
                               [elements insertObject:[[MosaicData alloc] initWithDictionary:cModuleDict] atIndex:4];
                               
                               [self performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:NO];
                           }
                           //到这里就是0条数据
                       }
                       [alerViewManager dismissMessageView:self.view];
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       // pass error to the block
                       NSLog(@"获取瀑布流json失败:%@",error);
                       [alerViewManager dismissMessageView:self.view];
                   }];
}


@end

//
//  DataViewController.m
//  RaidersDtcq
//
//  Created by 计 炜 on 14-3-9.
//  Copyright (c) 2014年 计 炜. All rights reserved.
//

#import "DataViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"

#import "ArticleItem.h"
#import "SVWebViewController.h"
#import "DetailViewController.h"
#import "GlobalConfigure.h"
#import "Globle.h"
#import "AlerViewManager.H"
#import "MJRefresh.h"

#define COLVIEW_HEIGHT 153.0
#define COUNT_PAGE 20

@interface DataViewController ()

@property (nonatomic) NSInteger receiveMember,pageNum,allPageNum;
@property (nonatomic, strong) MJRefreshHeaderView *header;
@property (nonatomic) AlerViewManager *alerViewManager;

@property (strong, nonatomic)  UIScrollView *scrollView;
@property (strong, nonatomic)  UICollectionView *collectView1;
@property (strong, nonatomic)  UICollectionView *collectView2;
@property (strong, nonatomic)  UICollectionView *collectView3;
@property (strong, nonatomic)  UICollectionView *collectView4;

- (void)getComments:(NSString* )slug;

@end

@implementation DataViewController
@synthesize dataList1,dataList2,dataList3,dataList4,alerViewManager;
@synthesize scrollView,collectView1,collectView2,collectView3,collectView4;
@synthesize receiveMember, pageNum, allPageNum,header;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        receiveMember = 0;
        pageNum = 0;
        allPageNum = 0;
        alerViewManager = [[AlerViewManager alloc] init];
        dataList1 = [[NSMutableArray alloc] init];
        dataList2 = [[NSMutableArray alloc] init];
        dataList3 = [[NSMutableArray alloc] init];
        dataList4 = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [header free];
    //[_footer free];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-88)];

    scrollView.backgroundColor = [UIColor whiteColor];
    // 是否支持滑动最顶端
    //    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    // 设置内容大小
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, COLVIEW_HEIGHT*3+44);
    // 是否反弹
    //    scrollView.bounces = NO;
    // 是否分页
    //    scrollView.pagingEnabled = YES;
    // 是否滚动
    scrollView.scrollEnabled = YES;
    //    scrollView.showsHorizontalScrollIndicator = NO;
    // 设置indicator风格
    //    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    // 设置内容的边缘和Indicators边缘
    //    scrollView.contentInset = UIEdgeInsetsMake(0, 50, 50, 0);
    //    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 50, 0, 0);
    // 提示用户,Indicators flash
    //[scrollView flashScrollIndicators];
    // 是否不允许同时左右与上下拖动
    scrollView.directionalLockEnabled = NO;
    [self.view addSubview:scrollView];

    
    LineLayout* lineLayout1 = [[LineLayout alloc] init];
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
//    [flowLayout setItemSize:CGSizeMake(80, 80)];
//    [flowLayout setMinimumInteritemSpacing:0.f];
//    [flowLayout setMinimumLineSpacing:0.f];
    collectView1 = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, COLVIEW_HEIGHT) collectionViewLayout:lineLayout1];
    collectView1.delegate = self;
    collectView1.dataSource = self;
    collectView1.backgroundView = [[UIView alloc] init];
    collectView1.backgroundView.backgroundColor = [UIColor whiteColor];
    [collectView1 registerClass:[dataCell class] forCellWithReuseIdentifier:@"dataViewCell"];
    [collectView1 registerClass:[CollectionHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"dataViewHead"];
    collectView1.tag = 10000;
    [self.scrollView addSubview:collectView1];
    UILabel *_label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 20)];
    _label1.text = @"力量型:";
    _label1.textAlignment = NSTextAlignmentLeft;
    _label1.font = [UIFont systemFontOfSize:16];
    [_label1 setTextColor:[UIColor colorWithRed:56.0/255.0 green:58.0/255.0 blue:90.0/255.0 alpha:1.0]];
    _label1.backgroundColor = [UIColor clearColor];
    [collectView1.backgroundView addSubview:_label1];
    UIView *bottomLine1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, COLVIEW_HEIGHT-1.0, [UIScreen mainScreen].bounds.size.width, 1.0f)];
    bottomLine1.backgroundColor = RGB(242,242,241);
    [collectView1.backgroundView addSubview:bottomLine1];
    
    
    LineLayout* lineLayout2 = [[LineLayout alloc] init];
    collectView2 = [[UICollectionView alloc] initWithFrame:CGRectMake(0, COLVIEW_HEIGHT, self.view.bounds.size.width, COLVIEW_HEIGHT) collectionViewLayout:lineLayout2];
    collectView2.delegate = self;
    collectView2.dataSource = self;
    collectView2.backgroundView = [[UIView alloc] init];
    collectView2.backgroundView.backgroundColor = [UIColor whiteColor];
    [collectView2 registerClass:[dataCell class] forCellWithReuseIdentifier:@"dataViewCell"];
    [collectView2 registerClass:[CollectionHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"dataViewHead"];
    collectView2.tag = 10001;
    [self.scrollView addSubview:collectView2];
    UILabel *_label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 20)];
    _label2.text = @"敏捷型:";
    _label2.textAlignment = NSTextAlignmentLeft;
    _label2.font = [UIFont systemFontOfSize:16];
    [_label2 setTextColor:[UIColor colorWithRed:56.0/255.0 green:58.0/255.0 blue:90.0/255.0 alpha:1.0]];
    _label2.backgroundColor = [UIColor clearColor];
    [collectView2.backgroundView addSubview:_label2];
    UIView *bottomLine2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, COLVIEW_HEIGHT-1.0, [UIScreen mainScreen].bounds.size.width, 1.0f)];
    bottomLine2.backgroundColor = RGB(242,242,241);
    [collectView2.backgroundView addSubview:bottomLine2];

    
    LineLayout* lineLayout3 = [[LineLayout alloc] init];
    collectView3 = [[UICollectionView alloc] initWithFrame:CGRectMake(0, COLVIEW_HEIGHT*2, self.view.bounds.size.width, COLVIEW_HEIGHT) collectionViewLayout:lineLayout3];
    collectView3.delegate = self;
    collectView3.dataSource = self;
    collectView3.backgroundView = [[UIView alloc] init];
    collectView3.backgroundView.backgroundColor = [UIColor whiteColor];
    [collectView3 registerClass:[dataCell class] forCellWithReuseIdentifier:@"dataViewCell"];
    [collectView3 registerClass:[CollectionHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"dataViewHead"];
    collectView3.tag = 10002;
    [self.scrollView addSubview:collectView3];
    UILabel *_label3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 20)];
    _label3.text = @"智力型:";
    _label3.textAlignment = NSTextAlignmentLeft;
    _label3.font = [UIFont systemFontOfSize:16];
    [_label3 setTextColor:[UIColor colorWithRed:56.0/255.0 green:58.0/255.0 blue:90.0/255.0 alpha:1.0]];
    _label3.backgroundColor = [UIColor clearColor];
    [collectView3.backgroundView addSubview:_label3];
    UIView *bottomLine3 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, COLVIEW_HEIGHT-1.0, [UIScreen mainScreen].bounds.size.width, 1.0f)];
    bottomLine3.backgroundColor = RGB(242,242,241);
    [collectView3.backgroundView addSubview:bottomLine3];
    
    
    LineLayout* lineLayout4 = [[LineLayout alloc] init];
    collectView4 = [[UICollectionView alloc] initWithFrame:CGRectMake(0, COLVIEW_HEIGHT*3, self.view.bounds.size.width, COLVIEW_HEIGHT) collectionViewLayout:lineLayout4];
    collectView4.delegate = self;
    collectView4.dataSource = self;
    collectView4.backgroundView = [[UIView alloc] init];
    collectView4.backgroundView.backgroundColor = [UIColor whiteColor];
    [collectView4 registerClass:[dataCell class] forCellWithReuseIdentifier:@"dataViewCell"];
    [collectView4 registerClass:[CollectionHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"dataViewHead"];
    collectView4.tag = 10003;
    //[self.scrollView addSubview:collectView4];//先禁掉第四行装备列
    collectView4.hidden = YES;
    UILabel *_label4 = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 20)];
    _label4.text = @"装备:";
    _label4.textAlignment = NSTextAlignmentLeft;
    _label4.font = [UIFont systemFontOfSize:16];
    [_label4 setTextColor:[UIColor colorWithRed:56.0/255.0 green:58.0/255.0 blue:90.0/255.0 alpha:1.0]];
    _label4.backgroundColor = [UIColor clearColor];
    [collectView4.backgroundView addSubview:_label4];
    UIView *bottomLine4 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, COLVIEW_HEIGHT-1.0, [UIScreen mainScreen].bounds.size.width, 1.0f)];
    bottomLine4.backgroundColor = RGB(242,242,241);
    [collectView4.backgroundView addSubview:bottomLine4];
    
    __unsafe_unretained DataViewController *vc = self;
    //添加下拉刷新
    header = [MJRefreshHeaderView header];
    header.scrollView = self.scrollView;
    
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        
        [vc.dataList1 removeAllObjects];
        [vc.collectView1 performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [vc.dataList2 removeAllObjects];
        [vc.collectView2 performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [vc.dataList3 removeAllObjects];
        [vc.collectView3 performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [vc.dataList4 removeAllObjects];
        [vc.collectView4 performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        vc->pageNum = 0;
        vc->allPageNum = 0;
        
        [vc performSelectorOnMainThread:@selector(getComments:) withObject:@"li-liang" waitUntilDone:NO];
        [vc performSelectorOnMainThread:@selector(getComments:) withObject:@"min-jie" waitUntilDone:NO];
        [vc performSelectorOnMainThread:@selector(getComments:) withObject:@"zhi-li" waitUntilDone:NO];
        //[vc performSelectorOnMainThread:@selector(getComments:) withObject:@"zhuang-bei" waitUntilDone:NO];
    };
    [header beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


///////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView.tag == 10000) {
        
        return [self.dataList1 count]==0 ? 0:[self.dataList1 count]+1;
    }else if (collectionView.tag == 10001) {
        return [self.dataList2 count]==0 ? 0:[self.dataList2 count]+1;
    }else if (collectionView.tag == 10002) {
        return [self.dataList3 count]==0 ? 0:[self.dataList3 count]+1;
    }else if (collectionView.tag == 10003) {
        return [self.dataList4 count]==0 ? 0:[self.dataList4 count]+1;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

// 返回headview或footview
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    CollectionHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"dataViewHead" forIndexPath:indexPath];
//    headView.label.text = @"力量型";
//    return headView;
//}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"dataViewCell";
    dataCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    //cell.label.text = [NSString stringWithFormat:@"%d",indexPath.item];
    
    //先去除掉可能有的boxView,防止重用时覆盖
    NSArray *subs = [cell subviews];
    for (UIView *boxViewin in subs) {
        if (boxViewin.tag == 2000) {
            [boxViewin removeFromSuperview];
        }
    }
    
    NSArray *dataList;
    if (collectionView.tag == 10000) {
        dataList = self.dataList1;
    }else if (collectionView.tag == 10001) {
        dataList = self.dataList2;
    }else if (collectionView.tag == 10002) {
        dataList = self.dataList3;
    }else if (collectionView.tag == 10003) {
        dataList = self.dataList4;
    }

    
    int nodeCount = [dataList count];
    if (nodeCount >0 && nodeCount > indexPath.row)
    {
        // Set up the cell...
        //LOG(@"长度:%d,%d",nodeCount,indexPath.row);
        ArticleItem *aArticle = [dataList objectAtIndex:indexPath.row];
        cell.label.text = aArticle.title;
        
//        cell.image.frame = CGRectMake(12.0f, 12.0f, 105.0f, 65.0f);
//        cell.label.frame = CGRectMake(12.0f, 12.0f, 105.0f, 65.0f);
        [cell.image setImageWithURL:aArticle.firstPicURL
                       placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
        
    }
    else if (nodeCount >0 && nodeCount <= indexPath.row) {
        UIView *box = [[UIView alloc] initWithFrame:cell.image.frame];
        box.backgroundColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1];
        box.tag = 2000;
        // add the add image
        UIImage *add = [UIImage imageNamed:@"add.png"];
        UIImageView *addView = [[UIImageView alloc] initWithImage:add];
        [box addSubview:addView];
        addView.center = (CGPoint){box.frame.size.width / 2, box.frame.size.height / 2};
        addView.alpha = 0.2;
        addView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleLeftMargin;
        cell.label.text = @"加载更多";
        if (nodeCount%COUNT_PAGE != 0) {
            cell.label.text = @"已全部加载";
        }
        [cell addSubview:box];
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LOG(@"点击:%@",indexPath);
    
    NSArray *dataList;
    if (collectionView.tag == 10000) {
        dataList = self.dataList1;
    }else if (collectionView.tag == 10001) {
        dataList = self.dataList2;
    }else if (collectionView.tag == 10002) {
        dataList = self.dataList3;
    }else if (collectionView.tag == 10003) {
        dataList = self.dataList4;
    }
    if ([dataList count] > indexPath.row) {
        DetailViewController *vc = [[DetailViewController alloc] initWithTitle:@"图鉴"];
        vc.appData = dataList;
        vc.startIndex = indexPath.row;
        
        //NSLog(@"didSelectArticle:%@",aArticle.content);
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        //加载更多
        if ([dataList count]%COUNT_PAGE != 0)
        {
            [alerViewManager showOnlyMessage:@"已全部加载" inView:self.view];
        }else {
            pageNum = [dataList count]/COUNT_PAGE +1;
            [self performSelectorOnMainThread:@selector(getComments:) withObject:@"zhuang-bei" waitUntilDone:NO];
            
//            [self.collectView4  performBatchUpdates:^{
//                [self.collectView4 insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]]];
//            } completion:nil];
        }
        
    }
    
    return;
}


///////////////////////////////////////////
#pragma mark - localfoo
- (void)getComments:(NSString* )slug {
    
    //[alerViewManager showMessage:@"正在加载数据" inView:self.view];
    NSString *starString =  [NSString stringWithFormat:@"%d", pageNum];
    NSString *countString =  [NSString stringWithFormat:@"%d", COUNT_PAGE];
    AFHTTPClient *jsonapiClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://dtcq.appgame.com/"]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"get_category_posts", @"json",
                                countString, @"count",
                                @"attachments", @"exclude",
                                slug, @"slug",
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
                           NSLog(@"获取分类json异常:图鉴");
                       }else {
                           receiveMember = [[responseDictionary objectForKey:@"count"] integerValue];
                           allPageNum = [[responseDictionary objectForKey:@"pages"] integerValue];
                           
                           if (receiveMember > 0 && allPageNum >= pageNum) {
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
                               
                               if ([slug isEqualToString:@"li-liang"]) {
                                   [collectView1 performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                               }else if([slug isEqualToString:@"min-jie"]) {
                                   [collectView2 performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                               }else if([slug isEqualToString:@"zhi-li"]) {
                                   [collectView3 performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                               }else if([slug isEqualToString:@"zhuang-bei"]) {
                                   [collectView4 performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                               }
                               //[self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                           }
                           //到这里就是0条数据
                       }
                       [alerViewManager dismissMessageView:self.view];
                       if (header.isRefreshing) {
                           [header endRefreshing];
                       }

                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       // pass error to the block
                       NSLog(@"获取分类json失败:%@",error);
                       if (header.isRefreshing) {
                           [header endRefreshing];
                       }
                       [alerViewManager dismissMessageView:self.view];
                   }];
}


@end

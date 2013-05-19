//
//  CommentViewController.m
//  AppGame
//
//  Created by 计 炜 on 13-4-15.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "CommentViewController.h"
#import "UIImageView+AFNetworking.h"
#import "IADisquser.h"
#import "IADisqusConfig.h"
#import "disqusCommentCell.h"
#import "IADisqusComment.h"
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"
#import "RSSParser.h"
#import "RSSItem.h"
#import "SVWebViewController.h"

@interface CommentViewController ()
- (void)disMiss;
- (void)getComments;
@end

@implementation CommentViewController

@synthesize comments,pullToRefreshTableView,webURL,nextCursor,thread;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url  threadID:(NSNumber *)threadID
{
    //self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self = [super initWithNibName:nil bundle:nil]) {
        // Custom initialization
        self.webURL = url;
        self.title = title;
        self.thread = [[NSNumber alloc] initWithInteger:[threadID integerValue]];
        self.nextCursor = nil;
        hasNext = false;
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 49, 25);
        [leftButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setShowsTouchWhenHighlighted:YES];
        [leftButton addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *temporaryLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        temporaryLeftBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.leftBarButtonItem = temporaryLeftBarButtonItem;
    }
    alerViewManager = [[AlerViewManager alloc] init];
    ifNeedFristLoading = YES;

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePanGesture:)];
    //panGesture.delegate = self;
    panGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:panGesture];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleSwipeGesture:)];
    swipeGesture.delegate = self;
    [swipeGesture setDirection:(UISwipeGestureRecognizerDirectionRight)];
    swipeGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:swipeGesture];
    
    return self;
}

- (void)disMiss {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0];
    comments = [[NSMutableArray alloc] init];
    start = 0;
    receiveMember = 0;
    
    pullToRefreshTableView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-20) withType: withStateViews];
    
    pullToRefreshTableView.delegate = self;
    pullToRefreshTableView.dataSource = self;
    pullToRefreshTableView.allowsSelection = YES;
    pullToRefreshTableView.backgroundColor = [UIColor clearColor];
    pullToRefreshTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [pullToRefreshTableView setHidden:YES];
    [self.view addSubview:pullToRefreshTableView];
    
    // set view's interface
    [self.pullToRefreshTableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    //UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getarticles)];
    //[self.navigationItem setRightBarButtonItem:refresh];
    
    // get array of articles
    [self getComments];
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
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//反选
//    ArticleItem *aComment = [self.comments objectAtIndex:indexPath.row];
//    SVWebViewController *viewController = [[SVWebViewController alloc] initWithHTMLString:aArticle URL:aArticle.articleURL];
//    
//    //NSLog(@"didSelectArticle:%@",aArticle.content);
//    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSString *article = [(ArticleItem *)[self.articles objectAtIndex:indexPath.row] description];
    //    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000);
    //    CGSize size = [article sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    return 62;//计算每一个cell的高度
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([comments count] == 0) {
        //  本方法是为了在数据未空时，让“下拉刷新”视图可直接显示，比较直观
        tableView.contentInset = UIEdgeInsetsMake(k_STATE_VIEW_HEIGHT, 0, 0, 0);
    }
    return [comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    disqusCommentCell *cell = (disqusCommentCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[disqusCommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // Leave cells empty if there's no data yet
    int nodeCount = [self.comments count];
    
    if (nodeCount > 0)
	{
        // Set up the cell...
        IADisqusComment *aComment = [self.comments objectAtIndex:indexPath.row];
        [cell setIndentationLevel:[aComment.level intValue]];
        cell.nameLabel.text = aComment.mediaURL;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        cell.dateLabel.text = [dateFormatter stringFromDate:aComment.date];
        
        cell.creatorLabel.text = aComment.authorName;
        //        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000);
        //        CGSize size = [aArticle.description sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        cell.articleLabel.text = aComment.rawMessage;
        //        cell.articleLabel.frame = CGRectMake(4.0, 52.0,
        //                                             CELL_CONTENT_WIDTH - (2 * CELL_CONTENT_MARGIN),
        //                                             45.0 + CELL_CONTENT_MARGIN);
        
        // Only load cached images; defer new downloads until scrolling ends
        //当tableview停下来的时候才下载缩略图
        //if (pullToRefreshTableView.dragging == NO && pullToRefreshTableView.decelerating == NO)
        [cell.imageView setImageWithURL:[NSURL URLWithString:aComment.authorAvatar]
                       placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
        
        [cell.nameLabel setFrame:CGRectMake(8.0+46.0+8.0, 16.0, 320.0-16.0-46.0, 20.0)];
        [cell.imageView setFrame:CGRectMake(8.0, 8.0, 46.0, 46.0)];
        [cell.articleLabel setFrame:CGRectMake(8.0+46.0+8.0, 9.0, 320.0-16.0-46.0-8.0, 30.0)];
        [cell.dateLabel setFrame:CGRectMake(8.0+46.0+8.0, 40.0, 100.0, 14.0)];
        [cell.creatorLabel setFrame:CGRectMake(8.0+46.0+8.0+8.0+100, 40.0, 100.0, 14.0)];
        [cell.nameLabel setHidden:YES];
        
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
                [comments removeAllObjects];
                start = 0;
                self.nextCursor = nil;
                [self performSelectorOnMainThread:@selector(getComments) withObject:nil waitUntilDone:NO];
                break;
            }
            case k_RETURN_LOADMORE:
            {
                start = [self.comments count]/25 + 1;
                
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
    //if (receiveMember  >= 25)
    if (hasNext)
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

#pragma mark - UIPanGestureRecognizer
- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //向右横扫返回上一层
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:{ //UIGestureRecognizerStateRecognized正常情况下只响应这个消息
            if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
                [[self navigationController] popViewControllerAnimated:YES];
                [self.view removeGestureRecognizer:gestureRecognizer];
            }
            break;
        }
        case UIGestureRecognizerStateFailed:{ //
            //NSLog(@"======UIGestureRecognizerStateFailed");
            break;
        }
        case UIGestureRecognizerStatePossible:{ //
            //NSLog(@"======UIGestureRecognizerStatePossible");
            break;
        }
        default:{
            break;
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"======handlePanGesture");
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:{ //UIGestureRecognizerStateRecognized正常情况下只响应这个消息
            //[self.view removeGestureRecognizer:gestureRecognizer];
            break;
        }
        case UIGestureRecognizerStateFailed:{ //
            //NSLog(@"======UIGestureRecognizerStateFailed");
            break;
        }
        case UIGestureRecognizerStatePossible:{ //
            //NSLog(@"======UIGestureRecognizerStatePossible");
            break;
        }
        default:{
            break;
        }
    }
}

- (void)handleGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    //点击显示或隐藏工具栏
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:{//正常情况下只响应这个消息
            break;
        }
        case UIGestureRecognizerStateFailed:{ //
            //NSLog(@"======UIGestureRecognizerStateFailed");
            break;
        }
        case UIGestureRecognizerStatePossible:{ //
            //NSLog(@"======UIGestureRecognizerStatePossible");
            break;
        }
        default:{
            break;
        }
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //NSLog(@"handle touch");
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //NSLog(@"1");
    return YES;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"2");
    return YES;
}

- (void)getComments {
    
    [alerViewManager showMessage:@"正在加载数据" inView:self.view];
        // make the parameters dictionary
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                DISQUS_API_SECRET, @"api_secret",
                                DISQUS_FORUM_NAME, @"forum",
                                self.webURL, @"thread:link",
                                self.nextCursor, @"cursor",
                                nil];
    
    if (![self.thread isEqualToNumber:[NSNumber numberWithInteger:-1]]) {
         parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    DISQUS_API_SECRET, @"api_secret",
                                    DISQUS_FORUM_NAME, @"forum",
                                    self.thread, @"thread",
                                    self.nextCursor, @"cursor",
                                    nil];
    }

    
    // send the request
    //[IADisquser getCommentsFromThreadLink:self.webURL
    [IADisquser getCommentsWithParameters:parameters
                                  success:^(NSArray *_comments, NSDictionary *_cursorDictionary){
                                      
                                      hasNext = [[_cursorDictionary objectForKey:@"hasNext"] intValue];
                                      self.nextCursor = [_cursorDictionary objectForKey:@"next"];
                                      receiveMember = [_comments count];
                                      if (receiveMember > 0) {
                                          for (IADisqusComment *aComment in _comments){
                                              //IADisqusComment *aComment = (IADisqusComment *)[_comments objectAtIndex:0];
                                              NSLog(@"comment:%@\n%@\n%@\n%@\n%@\n%@\n%@\n",aComment.authorName,aComment.authorAvatar,aComment.likes,aComment.rawMessage,aComment.commentID,aComment.parentID,aComment.mediaURL);
                                              // get the array of comments, reverse it (oldest comment on top)
                                              //self.comments = [[_comments reverseObjectEnumerator] allObjects];
                                              
                                              // start activity indicator
                                              //[[self indicator] stopAnimating];
                                              //[self.tableView setAlpha:1.0];
                                              
                                              // reload the table
                                              //[self.tableView reloadData];
                                          }
                                          for (IADisqusComment *commentItem in _comments) {
                                              [self.comments addObject:commentItem];
                                          }
                                          //self.comments = [NSMutableArray arrayWithArray:_comments];

                                          [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                                      }
                                      [alerViewManager dismissMessageView:self.view];
                                      if ([pullToRefreshTableView isHidden])
                                      {
                                          [pullToRefreshTableView setHidden:NO];
                                      }
                                  } fail:^(NSError *error) {
                                      NSLog(@"commentError:%@",error);
                                      [alerViewManager dismissMessageView:self.view];
                                      if ([pullToRefreshTableView isHidden])
                                      {
                                          [pullToRefreshTableView setHidden:NO];
                                      }
                                      // start activity indicator
                                      //[[self indicator] stopAnimating];
                                      //[self.tableView setAlpha:1.0];
                                      
                                      // alert the error
                                      //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Occured"
                                      //                                                        message:[error localizedDescription]
                                      //                                                       delegate:nil
                                      //                                              cancelButtonTitle:@"OK"
                                      //                                              otherButtonTitles:nil];
                                      //[alert show];
                                  }];

}

@end

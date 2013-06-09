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
#import "YIPopupTextView.h"
#import "AppDataSouce.h"
#import "GlobalConfigure.h"

@interface CommentViewController ()
- (void)disMiss;
- (void)getComments;
@property (nonatomic, copy) NSNumber *commentID;
@property (nonatomic, strong, readonly) UIButton *textViewBarButton;
- (void)goTextViewClicked:(UIButton *)sender;
@end

@implementation CommentViewController

@synthesize comments,pullToRefreshTableView,webURL,nextCursor,thread,textView,textViewBarButton,commentID;

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
        leftButton.frame = CGRectMake(0, 0, 50, 26);
        [leftButton setBackgroundImage:[UIImage imageNamed:@"Return.png"] forState:UIControlStateNormal];
        [leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [leftButton setShowsTouchWhenHighlighted:YES];
        [leftButton addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
        [leftButton setTitle:@" 正文" forState:UIControlStateNormal];
        [leftButton.titleLabel setFont:[UIFont boldSystemFontOfSize:11]];
        
        UIBarButtonItem *temporaryLeftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        temporaryLeftBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.leftBarButtonItem = temporaryLeftBarButtonItem;
    }
    alerViewManager = [[AlerViewManager alloc] init];
    ifNeedFristLoading = YES;

//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
//                                                                                 action:@selector(handlePanGesture:)];
//    //panGesture.delegate = self;
//    panGesture.cancelsTouchesInView = NO;
//    [self.view addGestureRecognizer:panGesture];
//    
//    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
//                                                                                       action:@selector(handleSwipeGesture:)];
//    swipeGesture.delegate = self;
//    [swipeGesture setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    swipeGesture.cancelsTouchesInView = NO;
//    [self.view addGestureRecognizer:swipeGesture];
    
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
    
    [self.pullToRefreshTableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    pullToRefreshTableView.delegate = self;
    pullToRefreshTableView.dataSource = self;
    pullToRefreshTableView.allowsSelection = YES;
    pullToRefreshTableView.backgroundColor = [UIColor clearColor];
    pullToRefreshTableView.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:244.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
    pullToRefreshTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    pullToRefreshTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [pullToRefreshTableView setHidden:NO];
    [self.view addSubview:pullToRefreshTableView];
    
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
        [self.navigationController setToolbarHidden:NO animated:animated];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        //IOS5
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top.png"] forBarMetrics:UIBarMetricsDefault];
        
        if ([self.navigationController.toolbar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
            [self.navigationController.toolbar setBackgroundImage:[UIImage imageNamed:@"fot.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        }
    }else {//IOS4
        
        [self.navigationController.toolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fot.png"]] atIndex:0];
    }
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //自定义toolbar按钮
    textViewBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    textViewBarButton.frame =CGRectMake(10, 5, 300, 33);
    [textViewBarButton setBackgroundImage:[UIImage imageNamed:@"Message-Box-long.png"] forState:UIControlStateNormal];
    [textViewBarButton addTarget: self action: @selector(goTextViewClicked:) forControlEvents: UIControlEventTouchUpInside];
    [self.navigationController.toolbar addSubview: textViewBarButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //[self.navigationController.navigationBar setAlpha:1.0f];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
    [textViewBarButton removeFromSuperview];
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

- (void)goTextViewClicked:(UIBarButtonItem *)sender {
    // NOTE: maxCount = 0 to hide count
    // YIPopupTextView* popupTextView = [[YIPopupTextView alloc] initWithPlaceHolder:@"input here" maxCount:1000];
    YIPopupTextView* popupTextView = [[YIPopupTextView alloc] initWithPlaceHolder:@"赞一个!"
                                                                         maxCount:1000
                                                                      buttonStyle:YIPopupTextViewButtonStyleLeftCancelRightDone
                                                                  tintsDoneButton:YES];
    popupTextView.delegate = self;
    popupTextView.caretShiftGestureEnabled = YES;   // default = NO
    popupTextView.text = self.textView;
    popupTextView.tag = 101;
    //    popupTextView.editable = NO;                  // set editable=NO to show without keyboard
    [popupTextView showInView:self.view];
    
    //
    // NOTE:
    // You can add your custom-button after calling -showInView:
    // (it's better to add on either superview or superview.superview)
    // https://github.com/inamiy/YIPopupTextView/issues/3
    //
    // [popupTextView.superview addSubview:customButton];
    //
}

#pragma mark -
#pragma mark YIPopupTextViewDelegate

- (void)popupTextView:(YIPopupTextView *)yitextView willDismissWithText:(NSString *)text cancelled:(BOOL)cancelled
{
    NSLog(@"will dismiss: cancelled=%d",cancelled);
    self.textView = text;
    NSLog(@"textView:%@",self.textView);
    if (!cancelled) {
        IADisquser *iaDisquser = [[IADisquser alloc] initWithIdentifier:@"disqus.com"];
        NSDictionary *parameters;
        if (yitextView.tag == 102) {
            parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                        kDataSource.credentialObject.accessToken, @"access_token",
                                        //DISQUS_API_SECRET, @"api_secret",
                                        DISQUS_API_PUBLIC,@"api_key",
                                        //dUser.userID, @"user",
                                        self.textView,@"message",
                                        self.commentID,@"parent",
                                        nil];
        }else if(yitextView.tag == 101) {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kDataSource.credentialObject.accessToken, @"access_token",
                                    //DISQUS_API_SECRET, @"api_secret",
                                    DISQUS_API_PUBLIC,@"api_key",
                                    //dUser.userID, @"user",
                                    self.textView,@"message",
                                    self.thread,@"thread",
                                    nil];
        }
        
        //create the post
        [iaDisquser postComment:parameters
                        success:^(NSDictionary *responseDictionary){
                            // check the code (success is 0)
                            NSNumber *code = [responseDictionary objectForKey:@"code"];
                            
                            if ([code integerValue] != 0) {   // there's an error
                                NSLog(@"评论发表异常");
                            }else {
                                NSArray *responseArray = [responseDictionary objectForKey:@"response"];
                                if ([responseArray count] != 0) {
                                    NSLog(@"成功发表评论:%@,%@", thread, self.textView);
                                }
                                //自动刷新评论,不过测试有延迟
//                                [comments removeAllObjects];
//                                start = 0;
//                                self.nextCursor = nil;
//                                [self performSelectorOnMainThread:@selector(getComments) withObject:nil waitUntilDone:NO];
                            }
                        }
                           fail:^(NSError *error) {
                               NSLog(@"发表评论失败:%@",error);
                           }];
    }
}

- (void)popupTextView:(YIPopupTextView *)textView didDismissWithText:(NSString *)text cancelled:(BOOL)cancelled
{
    NSLog(@"did dismiss: cancelled=%d",cancelled);
}

#pragma mark -
#pragma mark - UITableViewDelegate

//某一行被选中,由ViewController来实现push详细页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IADisqusComment *aComment = [self.comments objectAtIndex:indexPath.row];
    self.commentID = aComment.commentID;
    // NOTE: maxCount = 0 to hide count
    // YIPopupTextView* popupTextView = [[YIPopupTextView alloc] initWithPlaceHolder:@"input here" maxCount:1000];
    YIPopupTextView* popupTextView = [[YIPopupTextView alloc] initWithPlaceHolder:@"赞一个!"
                                                                         maxCount:1000
                                                                      buttonStyle:YIPopupTextViewButtonStyleLeftCancelRightDone
                                                                  tintsDoneButton:YES];
    popupTextView.delegate = self;
    popupTextView.caretShiftGestureEnabled = YES;   // default = NO
    popupTextView.text = self.textView;
    popupTextView.tag = 102;
    //    popupTextView.editable = NO;                  // set editable=NO to show without keyboard
    [popupTextView showInView:self.view];
    
    //
    // NOTE:
    // You can add your custom-button after calling -showInView:
    // (it's better to add on either superview or superview.superview)
    // https://github.com/inamiy/YIPopupTextView/issues/3
    //
    // [popupTextView.superview addSubview:customButton];
    //
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//反选
//    ArticleItem *aComment = [self.comments objectAtIndex:indexPath.row];
//    SVWebViewController *viewController = [[SVWebViewController alloc] initWithHTMLString:aArticle URL:aArticle.articleURL];
//    
//    //NSLog(@"didSelectArticle:%@",aArticle.content);
//    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    IADisqusComment *comment = (IADisqusComment *)[self.comments objectAtIndex:indexPath.row];
    CGSize constraint = CGSizeMake(320.0f - 52.0f, 20000);
    CGSize size = [comment.rawMessage sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    return MAX(size.height, 18.0f) + 34.0f;//计算每一个cell的高度
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
        
        CGSize constraint = CGSizeMake(320.0f-52.0f, 20000);
        CGSize size = [cell.articleLabel.text sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        [cell.articleLabel setFrame:CGRectMake(8.0+36.0+8.0, 26.0, 320.0-16.0-36.0-8.0, MAX(size.height, 18.0f))];

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
                                              NSLog(@"comment:%@\n%@\n%@\n%@\n%@\n%@\n%@\n",aComment.authorName,aComment.authorAvatar,aComment.likes,aComment.rawMessage,aComment.commentID,aComment.parentID,aComment.threadID);
                                              // get the array of comments, reverse it (oldest comment on top)
                                              //self.comments = [[_comments reverseObjectEnumerator] allObjects];
                                              self.thread = [[NSNumber alloc] initWithInteger:[aComment.threadID integerValue]];
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

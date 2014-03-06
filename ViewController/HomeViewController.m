//
//  HomeViewController.m
//  RaidersDOTA
//
//  Created by 计 炜 on 13-6-8.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "HomeViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"

#import "ArticleItem.h"
#import "ArticleItemCell.h"
#import "HomeViewCell.h"
#import "SVWebViewController.h"
#import "DetailViewController.h"
#import "GlobalConfigure.h"
#import "Globle.h"
#import "SearchViewController.h"

@interface HomeViewController ()
- (void)revealSidebar;
- (void)getDatas:(NSString *)slug;
- (void)goPopClicked:(UIBarButtonItem *)sender;
- (void)gotoSearch;//搜索文章
@end

@implementation HomeViewController

@synthesize dataList1,dataList2,dataList3,titleStr,categoryStr,webURL,myframe;
@synthesize segOneTableView,segTwoTableView,segmentedPerson,segThreeTableView,segOneBtn,segTwoBtn,segThreeBtn;

#pragma mark - View lifecycle
- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url withFrame:(CGRect)frame{
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = title;
        self.webURL = url;
        self.myframe = frame;
        
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
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 26, 26);
        [rightButton setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
        [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [rightButton setShowsTouchWhenHighlighted:YES];
        [rightButton addTarget:self action:@selector(gotoSearch:) forControlEvents:UIControlEventTouchUpInside];

        
        UIBarButtonItem *temporaryRightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        temporaryRightBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.rightBarButtonItem = temporaryRightBarButtonItem;
    }
    
    alerViewManager = [[AlerViewManager alloc] init];
    ifNeedFristLoading = YES;
    
    return self;
}

- (id)initWithTitle:(NSString *)title withUrl:(NSString *)url {
    return [self initWithTitle:title withUrl:url withFrame:CGRectMake(0, 0, [Globle shareInstance].globleWidth, [Globle shareInstance].globleHeight)];
}

- (id)initWithTitle:(NSString *)title withSeg:(NSArray *)seg withCate:(NSArray *)cate withFrame:(CGRect)frame{
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = title;
        self.myframe = frame;
        segStr = [[NSMutableArray alloc] init];
        categoryStr = [[NSMutableArray alloc] init];
        segStr = [seg mutableCopy];
        categoryStr = [cate mutableCopy];
        
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
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 22, 22);
        [rightButton setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
        [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [rightButton setShowsTouchWhenHighlighted:YES];
        [rightButton addTarget:self action:@selector(gotoSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIBarButtonItem *temporaryRightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        temporaryRightBarButtonItem.style = UIBarButtonItemStylePlain;
        self.navigationItem.rightBarButtonItem = temporaryRightBarButtonItem;
    }
    
    alerViewManager = [[AlerViewManager alloc] init];
    ifNeedFristLoading = YES;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = myframe;
    //self.view.frame = CGRectMake(0, 0, [Globle shareInstance].globleWidth, [Globle shareInstance].globleHeight);
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background-2.png"]];
    UIImage *image = [UIImage imageNamed:@"Background.png"];
    if (IPhone5) {
        image = [UIImage imageNamed:@"Backgroundh.png"];
    }
    UIImageView *bg = [[UIImageView alloc] initWithImage:image];
    bg.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    //bg.alpha = 0.5f;
    [self.view addSubview:bg];
    dataList1 = [[NSMutableArray alloc] init];
    dataList2 = [[NSMutableArray alloc] init];
    dataList3 = [[NSMutableArray alloc] init];
    start = 0;
    receiveMember = 0;
    start1 = 0;
    start2 = 0;
    receiveMember2 = 0;
    start3 = 0;
    receiveMember3 = 0;
    updating = NO;

    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(goPopClicked:)];
    swipeGesture.delegate = self;
    [swipeGesture setDirection:(UISwipeGestureRecognizerDirectionRight)];
    swipeGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:swipeGesture];
        
    segOneTableView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height-40) withType: withStateViews];//[[UIScreen mainScreen] bounds].size.height-20
    
    //[self.segOneTableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    segOneTableView.delegate = self;
    segOneTableView.dataSource = self;
    segOneTableView.allowsSelection = YES;
    segOneTableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        segOneTableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    }
    segOneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;//选中时cell样式
    segOneTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [segOneTableView setHidden:NO];
    segOneTableView.tag = 10001;
    [self.view addSubview:segOneTableView];

    segTwoTableView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height-40) withType: withStateViews];//[[UIScreen mainScreen] bounds].size.height-20
    

    segTwoTableView.delegate = self;
    segTwoTableView.dataSource = self;
    segTwoTableView.allowsSelection = YES;
    segTwoTableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        segTwoTableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    }
    segTwoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;//选中时cell样式
    segTwoTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [segTwoTableView setHidden:YES];
    segTwoTableView.tag = 10002;
    [self.view addSubview:segTwoTableView];

    segThreeTableView = [[PullToRefreshTableView alloc] initWithFrame: CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height-40) withType: withStateViews];//[[UIScreen mainScreen] bounds].size.height-20
    

    segThreeTableView.delegate = self;
    segThreeTableView.dataSource = self;
    segThreeTableView.allowsSelection = YES;
    segThreeTableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        segThreeTableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    }
    segThreeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;//选中时cell样式
    segThreeTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [segThreeTableView setHidden:YES];
    segThreeTableView.tag = 10003;
    [self.view addSubview:segThreeTableView];

    //添加选项卡
    //UIImageView *segBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"segmented-bg.png"]];
    UIView *segBg = [[UIView alloc] init];
    [segBg setFrame:CGRectMake(0, 0, 320, 40)];
    [segBg setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:segBg];
    segmentedPerson = [[AKSegmentedControl alloc] initWithFrame:CGRectMake(4, 6, 312, 28)];
    segmentedPerson.tag = 30002;
    [segmentedPerson addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    // Setting the resizable background image
    //UIImage *backgroundImage = [UIImage imageNamed:@"Subcategories.png"];
    //[segmentedPerson setBackgroundImage:backgroundImage];
    [segmentedPerson setBackgroundColor:[UIColor colorWithRed:233.0f/255.0f green:235.0f/255.0f blue:228.0f/255.0f alpha:1.0f]];
    // Setting the behavior mode of the control
    [segmentedPerson setSegmentedControlMode:AKSegmentedControlModeSticky];
    
    // Setting the separator image
    //[segmentedNews setSeparatorImage:[UIImage imageNamed:@"segmented-separator.png"]];
    
    UIImage *buttonBackground = [UIImage imageNamed:@"Subcategories.png"];//resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"Subcategories-pressed.png"];
    
    // Button 1
    segOneBtn = [[UIButton alloc] init];
    [segOneBtn setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [segOneBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateHighlighted];
    [segOneBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateSelected];
    [segOneBtn setBackgroundImage:buttonBackgroundPressed forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [segOneBtn setTitle:segStr[0] forState:UIControlStateNormal];
    [segOneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [segOneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [segOneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    //[buttonSocial setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[buttonSocial.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    [segOneBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
    //[segOneBtn.titleLabel setFont:[UIFont fontWithName:@"FZHuangCao-S09S" size:17.0]];
    //[buttonSocial setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    // Button 2
    segTwoBtn = [[UIButton alloc] init];
    [segTwoBtn setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [segTwoBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateHighlighted];
    [segTwoBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateSelected];
    [segTwoBtn setBackgroundImage:buttonBackgroundPressed forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [segTwoBtn setTitle:segStr[1] forState:UIControlStateNormal];
    [segTwoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [segTwoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [segTwoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    //[segTwoBtn.titleLabel setFont:[UIFont fontWithName:@"FZHuangCao-S09S" size:17.0]];
    [segTwoBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
    
    // Button 3
    segThreeBtn = [[UIButton alloc] init];
    [segThreeBtn setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [segThreeBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateHighlighted];
    [segThreeBtn setBackgroundImage:buttonBackgroundPressed forState:UIControlStateSelected];
    [segThreeBtn setBackgroundImage:buttonBackgroundPressed forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    [segThreeBtn setTitle:segStr[2] forState:UIControlStateNormal];
    [segThreeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [segThreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [segThreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    //[segThreeBtn.titleLabel setFont:[UIFont fontWithName:@"FZHuangCao-S09S" size:17.0]];
    [segThreeBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
    
    // Setting the UIButtons used in the segmented control
    [segmentedPerson setButtonsArray:@[segOneBtn,segTwoBtn,segThreeBtn]];
    [segmentedPerson setSelectedIndex:0];
    //[buttonSocial setHighlighted:YES];
    // Adding your control to the view
    [self.view addSubview:segmentedPerson];
    
    // get array of articles    
//    double delayInSeconds = 10.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
//                   ^(void){
//                       //your code here
//                       [self performSelectorInBackground:@selector(getDatas) withObject:nil];
//                   });
    //[self performSelectorInBackground:@selector(getDatas) withObject:nil];
    //[self performSelectorOnMainThread:@selector(getDatas) withObject:nil waitUntilDone:NO];
    [self getDatas:categoryStr[0]];
    [self getDatas:categoryStr[1]];
    [self getDatas:categoryStr[2]];
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

#pragma mark - AKSegmentedControl callbacks

- (void)segmentedControlValueChanged:(id)sender
{
    AKSegmentedControl *segmented = (AKSegmentedControl *)sender;
    NSLog(@"SegmentedControl : Selected Index %@,%d", [segmented selectedIndexes], segmented.tag);
    
    if ([segmented selectedIndexes].firstIndex == 0) {
        [self.segOneTableView setHidden:NO];
        [self.segTwoTableView setHidden:YES];
        [self.segThreeTableView setHidden:YES];
    }else if ([segmented selectedIndexes].firstIndex == 1){
        [self.segOneTableView setHidden:YES];
        [self.segTwoTableView setHidden:NO];
        [self.segThreeTableView setHidden:YES];
    }else if ([segmented selectedIndexes].firstIndex == 2){
        [self.segOneTableView setHidden:YES];
        [self.segTwoTableView setHidden:YES];
        [self.segThreeTableView setHidden:NO];
    }
}

#pragma mark - Class Methods
- (void)revealSidebar {
	_revealBlock();
}

- (void)gotoSearch{
    //设置搜索页出现
    //[self.RootScrollView setContentOffset:CGPointMake(6*320, 0) animated:YES];
    SearchViewController *searchController = [[SearchViewController alloc] initWithTitle:@"搜索" withFrame:CGRectMake(0, 0, 320, [Globle shareInstance].globleHeight-44-44)];
    
    [self.navigationController pushViewController:searchController animated:YES];
}

- (void)goPopClicked:(UIBarButtonItem *)sender {
    if ([[self navigationController].viewControllers count]>1)
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 10001) {
        [segOneTableView tableViewDidDragging];
    }else if (scrollView.tag == 10002) {
        [segTwoTableView tableViewDidDragging];
    }else if (scrollView.tag == 10003) {
        [segThreeTableView tableViewDidDragging];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{    
    if (scrollView.tag == 10001) {
        NSInteger returnKey = [segOneTableView tableViewDidEndDragging];
        
        //  returnKey用来判断执行的拖动是下拉还是上拖，如果数据正在加载，则返回DO_NOTHING
        if (returnKey != k_RETURN_DO_NOTHING)
        {
            NSString * key = [NSString stringWithFormat:@"%d", returnKey];
            [NSThread detachNewThreadSelector:@selector(updateThread:) toTarget:self withObject:key];
        }
    }else if (scrollView.tag == 10002) {
        NSInteger returnKey = [segTwoTableView tableViewDidEndDragging];
        
        //  returnKey用来判断执行的拖动是下拉还是上拖，如果数据正在加载，则返回DO_NOTHING
        if (returnKey != k_RETURN_DO_NOTHING)
        {
            NSString * key = [NSString stringWithFormat:@"%d", returnKey];
            [NSThread detachNewThreadSelector:@selector(updateThread2:) toTarget:self withObject:key];
        }
    }else if (scrollView.tag == 10003) {
        NSInteger returnKey = [segThreeTableView tableViewDidEndDragging];
        
        //  returnKey用来判断执行的拖动是下拉还是上拖，如果数据正在加载，则返回DO_NOTHING
        if (returnKey != k_RETURN_DO_NOTHING)
        {
            NSString * key = [NSString stringWithFormat:@"%d", returnKey];
            [NSThread detachNewThreadSelector:@selector(updateThread3:) toTarget:self withObject:key];
        }
    }
    
    if (!decelerate)
    {
        //[self loadImagesForOnscreenRows];
    }
}

#pragma mark -
#pragma mark - UITableViewDelegate

//某一行被选中,由ViewController来实现push详细页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *viewController = [[DetailViewController alloc] initWithTitle:self.title];
    if(tableView.tag == 10001){
        viewController.appData = self.dataList1;
    }else if(tableView.tag == 10002){
        viewController.appData = self.dataList2;
    }else if(tableView.tag == 10003){
        viewController.appData = self.dataList3;
    }
    viewController.startIndex = indexPath.row;

    //NSLog(@"didSelectArticle:%@",aArticle.content);
    [self.navigationController pushViewController:viewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//反选
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.tag == 10001){
        return 88.0f;
    }
    return 60.0f;
    
//    ArticleItem *aItem;
//    if(tableView.tag == 10001){
//        aItem = (ArticleItem *)[self.dataList1 objectAtIndex:indexPath.row];
//    }else if(tableView.tag == 10002){
//        aItem = (ArticleItem *)[self.dataList2 objectAtIndex:indexPath.row];
//    }else if(tableView.tag == 10003){
//        aItem = (ArticleItem *)[self.dataList3 objectAtIndex:indexPath.row];
//    }
//    
//    CGSize constraint = CGSizeMake(290.0f-16.0, 20000);
//    CGSize size = [aItem.title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
//    
//    return MAX(size.height, 20.0f) + 40.0f;//计算每一个cell的高度
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if ([comments count] == 0) {
//        //  本方法是为了在数据为空时，让“下拉刷新”视图可直接显示，比较直观
//        tableView.contentInset = UIEdgeInsetsMake(k_STATE_VIEW_HEIGHT, 0, 0, 0);
//    }
    if(tableView.tag == 10001){
        return [dataList1 count];
    }else if(tableView.tag == 10002){
        return [dataList2 count];
    }else if(tableView.tag == 10003){
        return [dataList3 count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HomeViewCell";
    if(tableView.tag == 10001){
        HomeViewCell *cell = (HomeViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[HomeViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        int nodeCount = [self.dataList1 count];
        if (nodeCount > 0)
        {
            // Set up the cell...
            ArticleItem *aArticle = [self.dataList1 objectAtIndex:indexPath.row];
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
    else if(tableView.tag == 10002){
        ArticleItemCell *cell = (ArticleItemCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ArticleItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"go.png"]];
        //cell.accessoryView.frame = CGRectMake(300, 20, 20, 20);
        // Leave cells empty if there's no data yet
        int nodeCount = [self.dataList2 count];
        
        if (nodeCount > 0)
        {
            // Set up the cell...
            ArticleItem *aComment = [self.dataList2 objectAtIndex:indexPath.row];
            cell.descriptLabel.text = aComment.description;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
            cell.dateLabel.text = [dateFormatter stringFromDate:aComment.pubDate];
            
            cell.creatorLabel.text = aComment.creator;
            cell.articleLabel.text = aComment.title;
            [cell.articleLabel setFrame:CGRectMake(8.0, 0.0, 290.0f-16.0, 60.0f)];
            
//            CGSize constraint = CGSizeMake(290.0f-16.0, 20000);
//            CGSize size = [cell.articleLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            //[cell.articleLabel setFrame:CGRectMake(8.0, 20.0, 290.0f-16.0, MAX(size.height, 20.0f))];
            
            //cell.imageView.image = [UIImage imageNamed:@"go.png"];
            //cell.imageView.frame = CGRectMake(320.0-30, (MAX(size.height, 20.0f)+20)/2, 20, 20);
            cell.imageView.hidden = YES;
            
        }
        
        return cell;
    }
    else if(tableView.tag == 10003){
        ArticleItemCell *cell = (ArticleItemCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ArticleItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        int nodeCount = [self.dataList3 count];
        
        if (nodeCount > 0)
        {
            // Set up the cell...
            ArticleItem *aComment = [self.dataList3 objectAtIndex:indexPath.row];
            cell.descriptLabel.text = aComment.description;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
            cell.dateLabel.text = [dateFormatter stringFromDate:aComment.pubDate];
            
            cell.creatorLabel.text = aComment.creator;
            cell.articleLabel.text = aComment.title;
            [cell.articleLabel setFrame:CGRectMake(8.0, 0.0, 290.0f-16.0, 60.0f)];
            
            cell.imageView.hidden = YES;
        }
        
        return cell;
    }
    return (ArticleItemCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
                start1 = 0;
                start = start1;
                [self performSelectorOnMainThread:@selector(getDatas:) withObject:categoryStr[0] waitUntilDone:NO];
                break;
            }
            case k_RETURN_LOADMORE:
            {
                start1 = [self.dataList1 count]/20 + 1;
                start = start1;
                [self performSelectorOnMainThread:@selector(getDatas:) withObject:categoryStr[0] waitUntilDone:NO];
                break;
            }
            default:
                break;
        }
    }
    [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
}

- (void)updateThread2:(NSString *)returnKey{
    @autoreleasepool {
        sleep(2);
        switch ([returnKey intValue]) {
            case k_RETURN_REFRESH:
            {
                [dataList2 removeAllObjects];
                start2 = 0;
                start = start2;
                [self performSelectorOnMainThread:@selector(getDatas:) withObject:categoryStr[1] waitUntilDone:NO];
                break;
            }
            case k_RETURN_LOADMORE:
            {
                start2 = [self.dataList2 count]/20 + 1;
                start = start2;
                [self performSelectorOnMainThread:@selector(getDatas:) withObject:categoryStr[1] waitUntilDone:NO];
                break;
            }
            default:
                break;
        }
    }
    [self performSelectorOnMainThread:@selector(updateTableView2) withObject:nil waitUntilDone:NO];
}

- (void)updateThread3:(NSString *)returnKey{
    @autoreleasepool {
        sleep(2);
        switch ([returnKey intValue]) {
            case k_RETURN_REFRESH:
            {
                [dataList3 removeAllObjects];
                start3 = 0;
                start = start3;
                [self performSelectorOnMainThread:@selector(getDatas:) withObject:categoryStr[2] waitUntilDone:NO];
                break;
            }
            case k_RETURN_LOADMORE:
            {
                start3 = [self.dataList3 count]/20 + 1;
                start = start3;
                [self performSelectorOnMainThread:@selector(getDatas:) withObject:categoryStr[2] waitUntilDone:NO];
                break;
            }
            default:
                break;
        }
    }
    [self performSelectorOnMainThread:@selector(updateTableView3) withObject:nil waitUntilDone:NO];
}

- (void)updateTableView
{
    if (receiveMember  >= 20)
        //if (hasNext)
    {
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果数据还能继续加载，则传入NO
        [segOneTableView reloadData:NO];
    }
    else
    {
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果已全部加载，则传入YES
        [segOneTableView reloadData:YES];
    }
}

- (void)updateTableView2
{
    if (receiveMember2  >= 20)
        //if (hasNext)
    {
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果数据还能继续加载，则传入NO
        [segTwoTableView reloadData:NO];
    }
    else
    {
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果已全部加载，则传入YES
        [segTwoTableView reloadData:YES];
    }
}

- (void)updateTableView3
{
    if (receiveMember3 >= 20)
        //if (hasNext)
    {
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果数据还能继续加载，则传入NO
        [segThreeTableView reloadData:NO];
    }
    else
    {
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        //如果已全部加载，则传入YES
        [segThreeTableView reloadData:YES];
    }
}

- (void)getDatas:(NSString *)slug {
    
    [alerViewManager showMessage:@"正在加载数据" inView:self.view];
    
    NSString *starString =  [NSString stringWithFormat:@"%d", start];
    AFHTTPClient *jsonapiClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://dtcq.appgame.com/"]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"get_category_posts", @"json",
                                @"20", @"count",                                
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
                           NSLog(@"获取文章json异常:%@",self.webURL);
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
                               
                               if ([slug isEqualToString:categoryStr[0]]) {                               
                                   for (ArticleItem *commentItem in _comments) {
                                       [self.dataList1 addObject:commentItem];
                                   }
                                   receiveMember = [[responseDictionary objectForKey:@"count"] integerValue];
                                   [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:YES];
                               }else if ([slug isEqualToString:categoryStr[1]]) {
                                   for (ArticleItem *commentItem in _comments) {
                                       [self.dataList2 addObject:commentItem];
                                   }
                                   receiveMember2 = [[responseDictionary objectForKey:@"count"] integerValue];
                                   [self performSelectorOnMainThread:@selector(updateTableView2) withObject:nil waitUntilDone:YES];
                               }else if ([slug isEqualToString:categoryStr[2]]) {
                                   for (ArticleItem *commentItem in _comments) {
                                       [self.dataList3 addObject:commentItem];
                                   }
                                   receiveMember3 = [[responseDictionary objectForKey:@"count"] integerValue];
                                   [self performSelectorOnMainThread:@selector(updateTableView3) withObject:nil waitUntilDone:YES];
                               }
                           }
                           //到这里就是0条数据
                       }
                       [alerViewManager dismissMessageView:self.view];
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       // pass error to the block
                       NSLog(@"获取文章json失败:%@",error);
                       [alerViewManager dismissMessageView:self.view];
                   }];
}

@end

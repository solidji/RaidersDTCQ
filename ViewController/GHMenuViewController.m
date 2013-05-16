//
//  GHMenuViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 1/3/12.
//  Copyright (c) 2012 Greg Haines. All rights reserved.
//

#import "GHMenuViewController.h"
#import "GHMenuCell.h"
#import "GHRevealViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDataSouce.h"//for login
#import "GlobalConfigure.h"
#import "UIImageView+AFNetworking.h"//为了头像

#pragma mark -
#pragma mark Implementation
@implementation GHMenuViewController {
	GHRevealViewController *_sidebarVC;
	UISearchBar *_searchBar;
	UITableView *_menuTableView;
	NSArray *_headers;
	NSArray *_controllers;
	NSArray *_cellInfos;
}

#pragma mark Memory Management
- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC 
					  withSearchBar:(UISearchBar *)searchBar 
						withHeaders:(NSArray *)headers 
					withControllers:(NSArray *)controllers 
					  withCellInfos:(NSArray *)cellInfos {
	if (self = [super initWithNibName:nil bundle:nil]) {
		_sidebarVC = sidebarVC;
		_searchBar = searchBar;
		_headers = headers;
		_controllers = controllers;
		_cellInfos = cellInfos;
		
		_sidebarVC.sidebarViewController = self;
		_sidebarVC.contentViewController = _controllers[0][0];//哪个页面为默认
	}
	return self;
}

#pragma mark UIViewController
- (void)viewDidLoad {
	[super viewDidLoad];
    
//    UIImageView *contentView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
//    [contentView setImage:[UIImage imageNamed:@"Basemap.png"]];
//    //[contentView setUserInteractionEnabled:YES];
//    [self.view addSubview:contentView];
    
	self.view.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	//[self.view addSubview:_searchBar];
	
	_menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds) - 0.0f)//44.0f
												  style:UITableViewStylePlain];
	_menuTableView.delegate = self;
	_menuTableView.dataSource = self;
	_menuTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	_menuTableView.backgroundColor = [UIColor clearColor];
	_menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _menuTableView.scrollEnabled = NO;//设置为不能拖动
	[self.view addSubview:_menuTableView];
	[self selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];//侧边栏选中哪一项
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));   
	//[_searchBar sizeToFit];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return (orientation == UIInterfaceOrientationPortraitUpsideDown)
		? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		: YES;
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_cellInfos[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHMenuCell";
    GHMenuCell *cell = (GHMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	NSDictionary *info = _cellInfos[indexPath.section][indexPath.row];
    
    //UIImageView *bgImage=[[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 26, 26)];
    //[bgImage setImage:info[kSidebarCellImageKey]];
    //[self.contentView addSubview:bgImage];
    
    //UIImageView *cellImg = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 26,26)];
    //[cellImg setImage:info[kSidebarCellImageKey]];
    //cell.imageView.image = info[kSidebarCellImageKey];
    //[cell.contentView addSubview:cellImg];
    
	cell.textLabel.text = info[kSidebarCellTextKey];
	cell.imageView.image = [UIImage imageNamed:info[kSidebarCellImageKey]];
    
    NSMutableString *image = info[kSidebarCellImageKey];
    NSMutableString* imageName=[NSMutableString stringWithString:image];
    [imageName insertString:@"-white" atIndex:(image.length-4)];
    cell.imageView.highlightedImage = [UIImage imageNamed:imageName];
    
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if(section == 0){return 44.0f;}
    return (_headers[section] == [NSNull null]) ? 0.0f : 21.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        NSObject *headerText = kDataSource.userObject.name;
        UIImageView *bgImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [bgImage setImage: [UIImage imageNamed:@"top.png"]];
        UIView *headerView = nil;
        if (headerText != [NSNull null]) {
            headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 44.0f)];
            [headerView addSubview:bgImage];
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0f, 0.0f,[UIScreen mainScreen].bounds.size.height, 44.0f)];
            textLabel.text = (NSString *) headerText;
            textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:([UIFont systemFontSize] * 1.4f)];
            //textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            //textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
            //		textLabel.textColor = [UIColor colorWithRed:(125.0f/255.0f) green:(129.0f/255.0f) blue:(146.0f/255.0f) alpha:1.0f];
            textLabel.textColor = [UIColor whiteColor];
            textLabel.backgroundColor = [UIColor clearColor];
            [headerView addSubview:textLabel];
            
            UIImageView *avatarImage=[[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 32, 32)];
            [avatarImage setImageWithURL:[NSURL URLWithString:kDataSource.userObject.authorAvatar]
                        placeholderImage:[UIImage imageNamed:@"IconPlaceholder.png"]];
            [headerView addSubview:avatarImage];

        }
        return headerView;
    }
    
	NSObject *headerText = _headers[section];    
    
    UIImageView *bgImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
    [bgImage setImage: [UIImage imageNamed:@"Title-Red.png"]];

	UIView *headerView = nil;
	if (headerText != [NSNull null]) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 22.0f)];
//		CAGradientLayer *gradient = [CAGradientLayer layer];
//		gradient.frame = headerView.bounds;
//		gradient.colors = @[
//			(id)[UIColor colorWithRed:(67.0f/255.0f) green:(74.0f/255.0f) blue:(94.0f/255.0f) alpha:1.0f].CGColor,
//			(id)[UIColor colorWithRed:(57.0f/255.0f) green:(64.0f/255.0f) blue:(82.0f/255.0f) alpha:1.0f].CGColor,
//		];
//		[headerView.layer insertSublayer:gradient atIndex:0];
		[headerView addSubview:bgImage];
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f,[UIScreen mainScreen].bounds.size.height, 22.0f)];//CGRectInset
		textLabel.text = (NSString *) headerText;
		textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:([UIFont systemFontSize] * 1.0f)];
		textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
//		textLabel.textColor = [UIColor colorWithRed:(125.0f/255.0f) green:(129.0f/255.0f) blue:(146.0f/255.0f) alpha:1.0f];
        //textLabel.textColor = [UIColor colorWithRed:(225.0f/255.0f) green:(174.0f/255.0f) blue:(174.0f/255.0f) alpha:1.0f];
        textLabel.textColor = [UIColor whiteColor];
		textLabel.backgroundColor = [UIColor clearColor];
		[headerView addSubview:textLabel];
		
		//UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		//topLine.backgroundColor = [UIColor colorWithRed:(78.0f/255.0f) green:(86.0f/255.0f) blue:(103.0f/255.0f) alpha:1.0f];
		//[headerView addSubview:topLine];
		
		//UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 21.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		//bottomLine.backgroundColor = [UIColor colorWithRed:(36.0f/255.0f) green:(42.0f/255.0f) blue:(5.0f/255.0f) alpha:1.0f];
		//[headerView addSubview:bottomLine];
	}
	return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	_sidebarVC.contentViewController = _controllers[indexPath.section][indexPath.row];
	[_sidebarVC toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
}

#pragma mark Public Methods
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
	[_menuTableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
	if (scrollPosition == UITableViewScrollPositionNone) {
		[_menuTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
	}
	_sidebarVC.contentViewController = _controllers[indexPath.section][indexPath.row];
}

- (void)reloadTable {
	[_menuTableView reloadData];
}

@end

//
//  EventTableHeaderView.h
//  PromoHeaderView
//
//  Created by Andy soonest on 11-11-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollPageDataSource.h"
#import "ScrollPageControl.h"
#import "ScrollPageView.h"

@interface TableHeaderView : UIView<UIScrollViewDelegate>
{
	ScrollPageView *scrollView;
	ScrollPageControl *pageControl;
	
	// To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
    
    NSTimer *timer;
    BOOL userScrolls;
}

@property (nonatomic, assign) id<ScrollPageDataSource> dataSource;
@property (nonatomic, retain) NSMutableArray *pages;


- (id)initWithFrame:(CGRect)frame withDataSource:(id<ScrollPageDataSource>)_dataSource withPageControlType:(NSString *)type;


- (void)resetPage;

- (void)reloadPage:(NSInteger)index;

- (void)startAutoChangePage;

- (void)stopAutoChangePage;

@end

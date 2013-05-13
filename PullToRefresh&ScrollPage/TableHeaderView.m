//
//  EventTableHeaderView.m
//  EventTableHeaderView
//
//  Created by Andy soonest on 11-11-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

//#import "GlobalConfigure.h"
#import "TableHeaderView.h"

@interface TableHeaderView (PrivateMethods)

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

@end

@implementation TableHeaderView
@synthesize dataSource;
@synthesize pages;

- (id)initWithFrame:(CGRect)frame withDataSource:(id<ScrollPageDataSource>)_dataSource withPageControlType:(NSString *)type
{
    if ((self = [super initWithFrame:frame])) {
        
        self.backgroundColor = [UIColor clearColor];
		self.dataSource = _dataSource;
        // Initialization UIScrollView
        int pageControlHeight = 16;
		scrollView = [[ScrollPageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];//pageControlHeight - 1)];
		pageControl = [[ScrollPageControl alloc] initWithFrame:CGRectMake(0, scrollView.frame.size.height-pageControlHeight, frame.size.width, pageControlHeight)];
        
        //if ([type isEqualToString:kTablePageTypeReview]) {
        UIImageView *pageControlBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScrollPageControlR.png"]];
        pageControlBack.frame = CGRectMake(0, frame.size.height - pageControlHeight - 1, frame.size.width, pageControlHeight);
        //[self addSubview:pageControlBack];
        //[pageControlBack release];
        //}
        //        else if ([type isEqualToString:kTablePageTypeEvents_Open]) {
        //            UIImageView *pageControlBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScrollPageControlE.png"]];
        //            pageControlBack.frame = CGRectMake(0, frame.size.height - pageControlHeight - 1, frame.size.width, pageControlHeight);
        //            [self addSubview:pageControlBack];
        //            [pageControlBack release];
        //        }
        
        
        
		[self addSubview:scrollView];
		[self addSubview:pageControl];
        
		int kNumberOfPages = [dataSource numberOfPages];
        
		// in the meantime, load the array with placeholders which will be replaced on demand
		NSMutableArray *views = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < kNumberOfPages; i++) {
			[views addObject:[NSNull null]];
		}
		self.pages = views;
		//[views release];
        
		// a page is the width of the scroll view
		scrollView.pagingEnabled = YES;
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.showsVerticalScrollIndicator = NO;
		scrollView.scrollsToTop = NO;
		scrollView.delegate = self;
        scrollView.backgroundColor = [UIColor clearColor];
        
		pageControl.numberOfPages = kNumberOfPages;
		pageControl.currentPage = 0;
		pageControl.backgroundColor = [UIColor clearColor];
		
        [pageControl setImagePageStateNormal:[UIImage imageNamed:@"dim.png"]];
        [pageControl setImagePageStateHightlighted:[UIImage imageNamed:@"active.png"]];
		// pages are created on demand
		// load the visible page
		// load the page on either side to avoid flashes when the user starts scrolling
		[self loadScrollViewWithPage:0];
		[self loadScrollViewWithPage:1];
		
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context    = UIGraphicsGetCurrentContext();
    // draw top line
    CGContextSetAllowsAntialiasing(context, YES);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0, self.frame.size.height); //start at this point
    CGContextAddLineToPoint(context,320,self.frame.size.height); //draw to this point
    CGContextStrokePath(context);// and now draw the Path!
    
    //    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0].CGColor);
    //    CGContextSetLineWidth(context, 1.0);
    //    CGContextMoveToPoint(context, 0, self.frame.size.height - 1); //start at this point
    //    CGContextAddLineToPoint(context,320,self.frame.size.height - 1); //draw to this point
    //    CGContextStrokePath(context);// and now draw the Path!
    
    return;
}

- (void)buttonAction:(id)sender
{
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(pageDidSelceted:)])
    {
        NSLog(@"((UIButton *)sender).tag == %d",((UIButton *)sender).tag);
        
        [self.dataSource pageDidSelceted:((UIButton *)sender).tag];
    }
}


- (void)resetPage;
{
    for(NSInteger i = 0; i < [self.pages count]; i++)
    {
        UIView *view = [pages objectAtIndex:i];
        
        if ((NSNull *)view != [NSNull null])
        {
            [view removeFromSuperview];
        }
    }
    
    [self.pages removeAllObjects];
    
    int kNumberOfPages = [dataSource numberOfPages];
    
    NSLog(@"pageControlUsed init === %d",kNumberOfPages);
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++) {
        [views addObject:[NSNull null]];
    }
    self.pages = views;
    //[views release];
    
    NSLog(@"self.imageViews == %d",[self.pages count]);
    
    
    pageControl.numberOfPages = kNumberOfPages;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    [pageControl setImagePageStateNormal:[UIImage imageNamed:@"dim.png"]];
    [pageControl setImagePageStateHightlighted:[UIImage imageNamed:@"active.png"]];
    
    [self loadScrollViewWithPage:pageControl.currentPage-1];
    [self loadScrollViewWithPage:pageControl.currentPage];
    [self loadScrollViewWithPage:pageControl.currentPage+1];
    
    
}

- (void)startAutoChangePage
{
    if(timer != nil)
        return;
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(autoChangePage) userInfo:nil repeats:YES]; //retain];
}

- (void)stopAutoChangePage
{
    [timer invalidate];//[timer release];timer = nil;
}

- (void)autoChangePage
{
    //需要调用的代码
    if (userScrolls) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        userScrolls = NO;
        return;
    }
    
    if(pageControl.currentPage < pageControl.numberOfPages-1)
    {
        pageControl.currentPage++;
        //        NSLog(@"pageControl.currentPage = %d",pageControl.currentPage);
        // update the scroll view to the appropriate page
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * (pageControl.currentPage) ;
        frame.origin.y = 0;
        [scrollView scrollRectToVisible:frame animated:YES];
        
        // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
        [self loadScrollViewWithPage:pageControl.currentPage - 1];
        [self loadScrollViewWithPage:pageControl.currentPage];
        [self loadScrollViewWithPage:pageControl.currentPage + 1];
        
        [pageControl setImagePageStateNormal:[UIImage imageNamed:@"dim.png"]];
        [pageControl setImagePageStateHightlighted:[UIImage imageNamed:@"active.png"]];
        
	}
    else
    {
        pageControl.currentPage = 0;
        
        // update the scroll view to the appropriate page
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * (pageControl.currentPage) ;
        frame.origin.y = 0;
        [scrollView scrollRectToVisible:frame animated:YES];
        
        // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
        [self loadScrollViewWithPage:pageControl.currentPage - 1];
        [self loadScrollViewWithPage:pageControl.currentPage];
        [self loadScrollViewWithPage:pageControl.currentPage + 1];
        
        [pageControl setImagePageStateNormal:[UIImage imageNamed:@"dim.png"]];
        [pageControl setImagePageStateHightlighted:[UIImage imageNamed:@"active.png"]];
        
    }
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}


- (void)reloadPage:(NSInteger)index
{
    id page = [pages objectAtIndex:index];
    
    if ([page isKindOfClass:[UIImageView class]])
    {
        [page removeFromSuperview];
    }
    
    [pages replaceObjectAtIndex:index withObject:[NSNull null]];
    
    //    [self loadScrollViewWithPage:pageControl.currentPage-1];
    [self loadScrollViewWithPage:pageControl.currentPage];
    //    [self loadScrollViewWithPage:pageControl.currentPage+1];
}


- (void)loadScrollViewWithPage:(int)page
{
    int kNumberOfPages = [dataSource numberOfPages];
    
    if (page < 0) return;
    if (page >= kNumberOfPages) return;
    
    
    id pageView = [pages objectAtIndex:page];
    
    if([pageView isKindOfClass:[NSNull class]])
    {
        NSLog(@"[pageL isKindOfClass:[NSNull class]]");
        //UIImage *image = [dataSource imageAtIndex:page];
        UIImageView *pageImageView = [dataSource imageAtIndex:page];
        if(pageImageView)
        {
            NSLog(@"pageL ready");
            pageView = (UIView *)pageView;
            pageView = [[UIView alloc] init];
            [pages replaceObjectAtIndex:page withObject:pageView];
            //[pageView release];
            
            // add the controller's view to the scroll view
            
            if (nil == ((UIView *)pageView).superview)
            {
                //UIImageView *pageImageView = [[UIImageView alloc] initWithImage:image];
                
                CGRect frame = scrollView.frame;
                frame.origin.x = frame.size.width * page;
                frame.origin.y = (frame.size.height - pageImageView.frame.size.height)/2;
                frame.size.height = pageImageView.frame.size.height;
                frame.size.width = pageImageView.frame.size.width;
                ((UIView *)pageView).frame = frame;
                
                if (nil == pageImageView.superview)
                {
                    frame.origin.x = 0;
                    frame.origin.y = 0;
                    pageImageView.frame = frame;
                    [pageView addSubview:pageImageView];
                    
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = frame;
                    button.tag = page;
                    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                    [pageView addSubview:button];
                }
                
                //[pageImageView release];
                
                [scrollView addSubview:((UIView *)pageView)];
            }
        }
        else
        {
            NSLog(@"pageL not ready");
            pageView = (UIImageView *)pageView;
            pageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableHeadHolder.png"]];
            [pages replaceObjectAtIndex:page withObject:pageView];
            //[pageView release];
            
            // add the controller's view to the scroll view
            
            if (nil == ((UIImageView *)pageView).superview)
            {
                CGRect frame = scrollView.frame;
                frame.origin.x = frame.size.width * page;
                frame.origin.y = (frame.size.height - ((UIImageView *)pageView).frame.size.height)/2;
                frame.size.height = ((UIImageView *)pageView).frame.size.height;
                frame.size.width = ((UIImageView *)pageView).frame.size.width;
                ((UIImageView *)pageView).frame = frame;
                [scrollView addSubview:((UIImageView *)pageView)];
            }
        }
    }
    
    // check if need download new pic
    if([pageView isKindOfClass:[UIImageView class]])
    {
        if(self.dataSource && [self.dataSource respondsToSelector:@selector(pageImageNeedDownlod:)])
        {
            [self.dataSource pageImageNeedDownlod:page];
        }
    }
    
    if(page*2+1 >= 3)
    {
        [self startAutoChangePage];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	
    [pageControl setImagePageStateNormal:[UIImage imageNamed:@"dim.png"]];
    [pageControl setImagePageStateHightlighted:[UIImage imageNamed:@"active.png"]];
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed = NO;
    userScrolls = YES;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
    userScrolls = YES;
}


- (void)dealloc {
    
    [timer invalidate];
    //[timer release];
    //timer = nil;
    //self.pages = nil;
	//[scrollView release];
	//[pageControl release];
    //[super dealloc];
}


@end

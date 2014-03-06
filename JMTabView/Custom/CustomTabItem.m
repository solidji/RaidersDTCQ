#import "CustomTabItem.h"

#define kTabDemoVerticalItemPaddingSize CGSizeMake(18., 0.)
#define kTabDemoVerticalItemFont [UIFont boldSystemFontOfSize:10.]

@implementation CustomTabItem

@synthesize alternateIcon = alternateIcon_;


- (CGSize) sizeThatFits:(CGSize)size;
{
    CGSize titleSize = [self.title sizeWithFont:kTabDemoVerticalItemFont];
    
    CGFloat titleWidth = titleSize.width;
    
    CGFloat iconWidth = [self.icon size].width;
    
    CGFloat width = (iconWidth > titleWidth) ? iconWidth : titleWidth;
    
    width += (kTabDemoVerticalItemPaddingSize.width * 2);
    
    CGFloat height = 44.;
    
    return CGSizeMake(64, height);
}

- (void)drawRect:(CGRect)rect;
{
    CGRect bounds = rect;
    CGFloat yOffset = kTabDemoVerticalItemPaddingSize.height + 1.;
    
    UIImage * iconImage = (self.highlighted || [self isSelectedTabItem]) ? self.alternateIcon : self.icon;
    
    // calculate icon position
    CGFloat iconWidth = [iconImage size].width;
    CGFloat iconMarginWidth = (bounds.size.width - iconWidth) / 2;
    
    [iconImage drawAtPoint:CGPointMake(iconMarginWidth, yOffset)];
    
    // calculate title position
    //CGFloat titleWidth = [self.title sizeWithFont:kTabDemoVerticalItemFont].width;
    //CGFloat titleMarginWidth = (bounds.size.width - titleWidth) / 2;
    
    //UIColor * textColor = self.highlighted ? [UIColor lightGrayColor] : [UIColor whiteColor];
    //UIColor * textColor = self.highlighted ? [UIColor brownColor] : [UIColor brownColor];
    //[textColor set];
    //[self.title drawAtPoint:CGPointMake(titleMarginWidth, yOffset + 32.) withFont:kTabDemoVerticalItemFont];
}

+ (CustomTabItem *)tabItemWithTitle:(NSString *)title icon:(UIImage *)icon alternateIcon:(UIImage *)alternativeIcon;
{
    CustomTabItem * tabItem = [[CustomTabItem alloc] initWithTitle:title icon:icon];
    tabItem.alternateIcon = alternativeIcon;
    return tabItem;
}

@end

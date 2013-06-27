//
//  GHSidebarMenuCell.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHMenuCell.h"


#pragma mark -
#pragma mark Constants
NSString const *kSidebarCellTextKey = @"CellText";
NSString const *kSidebarCellImageKey = @"CellImage";

#pragma mark -
#pragma mark Implementation
@implementation GHMenuCell
@synthesize tagLabel;

#pragma mark Memory Management
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.clipsToBounds = YES;
		
//		UIView *bgView = [[UIView alloc] init];
//		bgView.backgroundColor = [UIColor colorWithRed:(215.0f/255.0f) green:(215.0f/255.0f) blue:(215.0f/255.0f) alpha:1.0f];
//        self.selectedBackgroundView = bgView;
        //self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Gray.png"]];
		// 设置背景
        UIImageView *bgImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [bgImage setImage: [UIImage imageNamed:@"blue.png"]];
        [self setBackgroundView:bgImage];
        
        UIImageView *selectedbgImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [selectedbgImage setImage: [UIImage imageNamed:@"Click-effect.png"]];
        self.selectedBackgroundView = selectedbgImage;
		
		self.imageView.contentMode = UIViewContentModeCenter;
        
		tagLabel = [[UILabel alloc] init];
		self.tagLabel.font = [UIFont fontWithName:@"Helvetica" size:([UIFont systemFontSize] * 1.2f)];
		//self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		//self.textLabel.shadowColor = [UIColor colorWithRed:(107.0f/255.0f) green:(107.0f/255.0f) blue:(107.0f/255.0f) alpha:1.0f];
		//self.textLabel.textColor = [UIColor colorWithRed:(43.0f/255.0f) green:(43.0f/255.0f) blue:(43.0f/255.0f) alpha:1.0f];
        tagLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:tagLabel];
        
        //增加上下分割线
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		//topLine.backgroundColor = [UIColor colorWithRed:(188.0f/255.0f) green:(188.0f/255.0f) blue:(188.0f/255.0f) alpha:1.0f];
        topLine.backgroundColor = [UIColor colorWithRed:(77.0f/255.0f) green:(84.0f/255.0f) blue:(94.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:topLine];
		
//		UIView *topLine2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
//		topLine2.backgroundColor = [UIColor colorWithRed:(238.0f/255.0f) green:(238.0f/255.0f) blue:(238.0f/255.0f) alpha:1.0f];
//		[self.textLabel.superview addSubview:topLine2];
		
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 43.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		//bottomLine.backgroundColor = [UIColor colorWithRed:(149.0f/255.0f) green:(149.0f/255.0f) blue:(149.0f/255.0f) alpha:1.0f];
        bottomLine.backgroundColor = [UIColor colorWithRed:(28.0f/255.0f) green:(29.0f/255.0f) blue:(31.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:bottomLine];
	}
	return self;
}

#pragma mark UIView
- (void)layoutSubviews {
	[super layoutSubviews];
	self.tagLabel.frame = CGRectMake(40.0f, 0.0f, 200.0f, 44.0f);
	//self.imageView.frame = CGRectMake(0.0f, 0.0f, 52.0f, 44.0f);
    self.imageView.frame = CGRectMake(10.0f, 12.0f, 20.0f, 20.0f);
    if([self.tagLabel.text isEqualToString:@"个人"] || [self.tagLabel.text isEqualToString:@"设置"])
    {
        self.tagLabel.frame = CGRectMake(70.0f, 0.0f, 200.0f, 44.0f);
        self.imageView.frame = CGRectMake(40.0f, 12.0f, 20.0f, 20.0f);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        self.tagLabel.textColor = [UIColor colorWithRed:(2.0f/255.0f) green:(46.0f/255.0f) blue:(77.0f/255.0f) alpha:1.0f];
        //[(UIButton *)self.accessoryView setHighlighted:NO];
        [self.imageView setHighlighted:YES];
        //[self.textLabel setHighlighted:YES];
    }
    else {
        self.tagLabel.textColor = [UIColor whiteColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.tagLabel.textColor = [UIColor colorWithRed:(2.0f/255.0f) green:(46.0f/255.0f) blue:(77.0f/255.0f) alpha:1.0f];
        [self.imageView setHighlighted:YES];
    }
    else {
        self.tagLabel.textColor = [UIColor whiteColor];
        [self.imageView setHighlighted:NO];
    }
    [self setNeedsDisplay];
}

@end

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
        [bgImage setImage: [UIImage imageNamed:@"gray.png"]];
        [self setBackgroundView:bgImage];
        
        UIImageView *selectedbgImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [selectedbgImage setImage: [UIImage imageNamed:@"Click-effect.png"]];
        self.selectedBackgroundView = selectedbgImage;

		
		self.imageView.contentMode = UIViewContentModeCenter;
		
		self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:([UIFont systemFontSize] * 1.2f)];
		//self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		//self.textLabel.shadowColor = [UIColor colorWithRed:(107.0f/255.0f) green:(107.0f/255.0f) blue:(107.0f/255.0f) alpha:1.0f];
		self.textLabel.textColor = [UIColor colorWithRed:(43.0f/255.0f) green:(43.0f/255.0f) blue:(43.0f/255.0f) alpha:1.0f];
        
        //增加上下分割线
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		topLine.backgroundColor = [UIColor colorWithRed:(188.0f/255.0f) green:(188.0f/255.0f) blue:(188.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:topLine];
		
		UIView *topLine2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		topLine2.backgroundColor = [UIColor colorWithRed:(238.0f/255.0f) green:(238.0f/255.0f) blue:(238.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:topLine2];
		
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 43.0f, [UIScreen mainScreen].bounds.size.width, 1.0f)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(149.0f/255.0f) green:(149.0f/255.0f) blue:(149.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:bottomLine];
	}
	return self;
}

#pragma mark UIView
- (void)layoutSubviews {
	[super layoutSubviews];
	self.textLabel.frame = CGRectMake(40.0f, 0.0f, 200.0f, 44.0f);
	//self.imageView.frame = CGRectMake(0.0f, 0.0f, 52.0f, 44.0f);
    self.imageView.frame = CGRectMake(10.0f, 12.0f, 20.0f, 20.0f);
    if([self.textLabel.text isEqualToString:@"个人"] || [self.textLabel.text isEqualToString:@"设置"])
    {
        self.textLabel.frame = CGRectMake(70.0f, 0.0f, 200.0f, 44.0f);
        self.imageView.frame = CGRectMake(40.0f, 12.0f, 20.0f, 20.0f);
    }
}

//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//    [super setHighlighted:highlighted animated:animated];
//
//    if (highlighted) {
////        NSString *imageName = [[NSString alloc] initWithFormat:@"%@-white.png", self.imageView];
////        self.imageView.image = [UIImage imageNamed:imageName];
//        [self.imageView setHighlighted:YES];
////        UIImageView *bgImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
////        [bgImage setImage: [UIImage imageNamed:@"Click-effect.png"]];
////        [self setSelectedBackgroundView:bgImage];
//    }else {
////        UIImageView *bgImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
////        [bgImage setImage: [UIImage imageNamed:@"Gray.png"]];
////        [self setBackgroundView:bgImage];
//        [self.imageView setHighlighted:NO];
//    }
//    [self setNeedsDisplay];
//    //tableCellContent.ifSelected = highlighted;
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    if(selected) {
        //[(UIButton *)self.accessoryView setHighlighted:NO];
        [self.imageView setHighlighted:YES];
    }
}

@end

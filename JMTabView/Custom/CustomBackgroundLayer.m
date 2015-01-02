//  Created by Jason Morrissey

#import "CustomBackgroundLayer.h"
#import "UIColor+Hex.h"
#import "AGConstants.h"

@implementation CustomBackgroundLayer

-(id)init;
{
    self = [super init];
    if (self)
    {
//        CAGradientLayer * gradientLayer = [[CAGradientLayer alloc] init];
//        UIColor * startColor = [UIColor colorWithHex:0x4a4b4a];
//        UIColor * midColor = [UIColor colorWithHex:0x282928];
//        UIColor * endColor = [UIColor colorWithHex:0x4a4b4a];
//        gradientLayer.frame = CGRectMake(0, 8., 1024, 60);
//        gradientLayer.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[midColor CGColor], (id)[endColor CGColor], nil];
//        [self insertSublayer:gradientLayer atIndex:0];
        
        //self.contents = (id)[UIImage imageNamed:@"UserAlertBack.png"].CGImage;
        
        CALayer * imageLayer = [CALayer layer];
        //层的  大小
        imageLayer.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44);
        //设置委圆角
        //imageLayer.cornerRadius = 10.0;
        //设置剪辑
        imageLayer.masksToBounds = YES;
        //加载图片
        imageLayer.backgroundColor = [UIColor colorWithRed:228/255.0f green:228/255.0f blue:228/255.0f alpha:1.0].CGColor;
        //imageLayer.contents = (id)kAGTabbarImage.CGImage;
        // 加载  层
        [self addSublayer:imageLayer];
    }
    return self;
}

@end

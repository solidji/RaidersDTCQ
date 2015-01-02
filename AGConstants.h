//
//  AGConstants.h
//  THPokerCommunity
//
//  Created by Mao on 14/11/12.
//  Copyright (c) 2014年 AppGame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern int ddLogLevel;

@interface AGConstants : NSObject{
    
}
+ (instancetype)sharedInstance;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@end

//static NSString *const AGActivity_URL        = @"http://activity.static.appgame.com/activity/app/";
//static NSString *const AGPassport_URL        = @"http://passport.appgame.com/user/create";
//
//static NSString* AVOSCloudAppID              = @"pb24ikpgqlvjkryun7auwyzg95wd53uclinh79t38tyxzgjm";
//static NSString* AVOSCloudAppKey             = @"mk5l6t0dlknzoa0hp85f194szempk1al9bqz620lksekhx6x";
//static NSString* kAGModelKey                 = @"kAGModelKey";
//
//static NSString* AGShowLoginViewNotification = @"AGShowLoginViewNotification";
//static NSString* AGVideoInfoNotification     = @"AGVideoInfoNotification";
//
//// 任玩堂账户中心Oauth2
//static NSString *const kBaseURL      = @"http://passport.appgame.com/oauth/access_token";
//static NSString *const kResourceURL  = @"http://passport.appgame.com/resource/userinfo";
//static NSString *const kClientID     = @"iosapp01";
//static NSString *const kClientSecret = @"9538e6e7d45d86fb8b88d3df0184fe80";

//#define kAGNoAvatarImage [UIImage imageNamed:@"noavatar_middle"]
#define kAGTabbarImage [UIImage imageNamed:@"tabbarbg.png"]
#define kAGNavibarImage [UIImage imageNamed:@"top.png"]
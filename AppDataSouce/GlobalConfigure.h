//
//  GlobalConfigure.h
//  AppGame
//
//  Created by ji wei on 13-5-16.
//  Copyright (c) 2013年 Appgame. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

//################################  不可修改部分 ################################

#define kAppDelegate            ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define kResoucePath            ((AppDelegate *)[[UIApplication sharedApplication] delegate]).resoucePath
#define kImageCachesPath        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).imageCachesPath
#define kIfNeedCleanCaches      ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ifCleanCaches

#define kDataSource             [AppDataSouce shareInstance]


//################ USER Keys ################
#define kIfiPhone5                  @"kIfiPhone5"
#define kIfDoneCompleteCheck        @"completecheck"
#define kDeviceCodeKey              @"devicecode"
#define kDeviceTokenKey             @"devicetoken"
#define kPushSetKey                 @"pushset"

#define kReviewTrollerRunCountDefault @"kReviewTrollerRunCountDefault"
#define kReviewTrollerDoneDefault @"kReviewTrollerDoneDefault"
#define kPushDefault @"kPushDefault"

#define kUserIDKey                  @"userid"
#define kNickNameKey                @"nickname"
#define kAccessToken                @"access_token"
#define kIfLogin                    @"ifLogin"
#define kUsername                   @"username"
#define kPassword                   @"password"
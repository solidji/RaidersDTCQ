//
//  IADisqusUser.h
//  Disquser
//
//  Created by ji wei on 13-1-18.
//  Copyright (c) 2013年 Beetlebox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IADisqusUser : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *about;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *numPosts;
@property (nonatomic, strong) NSNumber *numFollowers;
@property (nonatomic, strong) NSNumber *numFollowing;
@property (nonatomic, strong) NSNumber *numLikesReceived;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *profileUrl;

@property (nonatomic, strong) NSNumber *reputation;
@property (nonatomic, copy) NSString *location;

@property (nonatomic, strong) NSDate *joinedAt;
@property (nonatomic, strong) NSNumber *userID;
@property (nonatomic, copy) NSString *authorAvatar;

@end

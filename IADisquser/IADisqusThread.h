//
//  IADisqusThread.h
//  Disquser
//
//  Created by ji wei on 13-1-18.
//  Copyright (c) 2013年 Beetlebox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IADisqusThread : NSObject

@property (nonatomic, copy) NSNumber *authorID;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *dislikes;
@property (nonatomic, copy) NSString *feed;
@property (nonatomic, copy) NSString *forumName;
@property (nonatomic, strong) NSNumber *threadID;
@property (nonatomic, copy) NSString *threadIdentifier;

@property (nonatomic, strong) NSNumber *likes;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSNumber *posts;
@property (nonatomic, strong) NSNumber *postsInInterval;

@property (nonatomic, copy) NSString *title;


@end

//
//  AppDataSouce.m
//  GetApps
//
//  Created by lilian on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDataSouce.h"

@implementation AppDataSouce


@synthesize userObject;
@synthesize credentialObject;

@synthesize reviewPromoList;
@synthesize reviewList;
@synthesize reviewOtherList;


@synthesize gameList;
@synthesize guideList;
@synthesize raidersList;


@synthesize eventPromoList;
@synthesize eventOpenList;
@synthesize eventEndList;

@synthesize changeList;
@synthesize tradeList;

@synthesize treasureList;
@synthesize joinEventList;
@synthesize collectList;


+ (AppDataSouce *)shareInstance 
{
    static id instanceObj = nil;
    if(instanceObj != nil)
        return instanceObj;
    
    instanceObj = [[AppDataSouce alloc] init];
    return instanceObj;
}

- (id)init {
    self = [super init];
    if (self) {
        
        IADisqusUser *user = [[IADisqusUser alloc] init];
        self.userObject = user;

        
        AFOAuthCredential *credential = [[AFOAuthCredential alloc] init];
        self.credentialObject = credential;
        
        //评测
        NSMutableArray *reviewPromoArray = [[NSMutableArray alloc] init];
        self.reviewPromoList = reviewPromoArray;

        
        NSMutableArray *reviewArray = [[NSMutableArray alloc] init];
        self.reviewList = reviewArray;

        
        NSMutableArray *reviewOtherArray = [[NSMutableArray alloc] init];
        self.reviewOtherList = reviewOtherArray;

        
        
        //新游
        NSMutableArray *gameArray = [[NSMutableArray alloc] init];
        self.gameList = gameArray;

        
        NSMutableArray *guideArray = [[NSMutableArray alloc] init];
        self.guideList = guideArray;
        
        NSMutableArray *raidersArray = [[NSMutableArray alloc] init];
        self.raidersList = raidersArray;
        

        
        
        //活动
        NSMutableArray *eventPromoArray = [[NSMutableArray alloc] init];
        self.eventPromoList = eventPromoArray;
        
        NSMutableArray *eventOpenArray = [[NSMutableArray alloc] init];
        self.eventOpenList = eventOpenArray;

        
        NSMutableArray *eventEndArray = [[NSMutableArray alloc] init];
        self.eventEndList = eventEndArray;
        
        
        //商城
        NSMutableArray *changeArray = [[NSMutableArray alloc] init];
        self.changeList = changeArray;
        
        NSMutableArray *tradeArray = [[NSMutableArray alloc] init];
        self.tradeList = tradeArray;
        
        
        //gerne 
        NSMutableArray *treasureArray = [[NSMutableArray alloc] init];
        self.treasureList = treasureArray;
        
        NSMutableArray *joinEventArray = [[NSMutableArray alloc] init];
        self.joinEventList = joinEventArray;
        
        NSMutableArray *collectEndArray = [[NSMutableArray alloc] init];
        self.collectList = collectEndArray;

    }
    return self;
}

@end

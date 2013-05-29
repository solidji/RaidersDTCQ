//
//  AppDataSouce.h
//  GetApps
//
//  Created by lilian on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IADisqusUser.h"
#import "AFOAuth2Client.h"
#import "GHMenuViewController.h"

@interface AppDataSouce : NSObject
{

}

+ (AppDataSouce *)shareInstance;

@property (nonatomic, retain) GHMenuViewController      *menuController;
@property (nonatomic, retain) IADisqusUser              *userObject;
@property (nonatomic, retain) AFOAuthCredential       *credentialObject;

@property (nonatomic, retain) NSMutableArray          *reviewPromoList;
@property (nonatomic, retain) NSMutableArray          *reviewList;
@property (nonatomic, retain) NSMutableArray          *reviewOtherList;


@property (nonatomic, retain) NSMutableArray          *gameList;
@property (nonatomic, retain) NSMutableArray          *guideList;
@property (nonatomic, retain) NSMutableArray          *raidersList;


@property (nonatomic, retain) NSMutableArray          *eventPromoList;
@property (nonatomic, retain) NSMutableArray          *eventOpenList;
@property (nonatomic, retain) NSMutableArray          *eventEndList;


@property (nonatomic, retain) NSMutableArray          *changeList;
@property (nonatomic, retain) NSMutableArray          *tradeList;


@property (nonatomic, retain) NSMutableArray          *treasureList;
@property (nonatomic, retain) NSMutableArray          *joinEventList;
@property (nonatomic, retain) NSMutableArray          *collectList;


@end

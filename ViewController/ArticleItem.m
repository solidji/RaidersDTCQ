//
//  ArticleItem.m
//  AppGame
//
//  Created by 计 炜 on 13-3-2.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import "ArticleItem.h"

@implementation ArticleItem

@synthesize articleURL = _strArticleURL;
@synthesize title = _strTitle;
@synthesize iconURL = _strIconURL;
@synthesize category = _strCategory;
@synthesize pubDate = _strPubDate;
@synthesize creator = _strCreator;
@synthesize description = _strDescription;
@synthesize content = _strContent;

- (BOOL)isEqual:(id)anObject {
    if (![anObject isKindOfClass:[ArticleItem class]]) return NO;
    ArticleItem *otherObject = (ArticleItem *)anObject;
    return [self.title isEqual:otherObject.title] && [self.iconURL isEqual:otherObject.iconURL] && [self.articleURL isEqual:otherObject.articleURL];
}

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.title = [coder decodeObjectForKey:@"title"];
        self.iconURL = [coder decodeObjectForKey:@"iconURL"];
        self.articleURL = [coder decodeObjectForKey:@"articleURL"];
        self.category = [coder decodeObjectForKey:@"category"];
        self.pubDate = [coder decodeObjectForKey:@"pubDate"];
        self.creator = [coder decodeObjectForKey:@"creator"];
        self.description = [coder decodeObjectForKey:@"description"];
        self.content = [coder decodeObjectForKey:@"content"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.iconURL forKey:@"iconURL"];
    [coder encodeObject:self.articleURL forKey:@"articleURL"];
    [coder encodeObject:self.category forKey:@"category"];
    [coder encodeObject:self.pubDate forKey:@"pubDate"];
    [coder encodeObject:self.creator forKey:@"creator"];
    [coder encodeObject:self.description forKey:@"description"];
    [coder encodeObject:self.content forKey:@"content"];
}
@end
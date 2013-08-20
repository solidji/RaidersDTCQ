//
//  ArticleItem.h
//  AppGame
//
//  Created by 计 炜 on 13-3-2.
//  Copyright (c) 2013年 计 炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleItem : NSObject {
@private
    
    NSString *_strTitle;                //文章标题    
    NSString *_strCategory;             //文章分类 type
    NSDate   *_strPubDate;              //发布日期
    
    NSURL    *_strArticleURL;           //文章url
    NSURL    *_strArticleIconURL;       //文章缩略图url
    NSString *_strDescription;          //文章描述
    NSString *_strContent;              //文章正文
    NSNumber *_strcommentCount;             //文章评论数
    
    NSString *_strCreator;              //文章作者
    NSURL    *_strIconURL;              //作者头像url
    NSNumber *_strUserID;               //关注与粉丝列表中的用户ID,既文章作者ID
    
    NSString *_strTag;                  //文章标签 app_xxx
    NSURL    *_strFirstPicURL;          //文章第一张附件图url
}

@property (nonatomic, strong) NSURL *articleURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSURL *iconURL;
@property (nonatomic, strong) NSURL *articleIconURL;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, strong) NSDate *pubDate;
@property (nonatomic, copy) NSString *creator;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSNumber *userID;
@property (nonatomic, strong) NSNumber *commentCount;

@property (nonatomic, copy) NSString *tag;
@property (nonatomic, strong) NSURL *firstPicURL;
- (BOOL)isEqual:(id)anObject;

@end

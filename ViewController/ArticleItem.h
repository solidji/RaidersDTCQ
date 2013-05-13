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
    
    NSURL    *_strArticleURL;           //文章url
    NSString *_strTitle;                //文章标题
    NSURL    *_strIconURL;              //缩略图url
    NSString *_strCategory;             //文章分类
    NSDate   *_strPubDate;              //发布日期
    NSString *_strCreator;              //文章作者
    NSString *_strDescription;          //文章描述
    NSString *_strContent;              //文章正文
}

@property (nonatomic, strong) NSURL *articleURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSURL *iconURL;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, strong) NSDate *pubDate;
@property (nonatomic, copy) NSString *creator;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *content;

- (BOOL)isEqual:(id)anObject;

@end

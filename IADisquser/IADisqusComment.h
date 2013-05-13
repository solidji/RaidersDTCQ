//
// IADisqusComment.h
// Disquser
// 
// Copyright (c) 2011 Ikhsan Assaat. All Rights Reserved 
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


#import <Foundation/Foundation.h>

@interface IADisqusComment : NSObject

@property (nonatomic, copy) NSString *forumName;

@property (nonatomic, copy) NSString *authorName;//评论作者名author/name
@property (nonatomic, copy) NSString *authorAvatar;//评论作者头像avatar/small/cache
@property (nonatomic, copy) NSString *authorEmail;
@property (nonatomic, copy) NSString *authorURL;
@property (nonatomic, strong) NSNumber *threadID;//threadID thread

@property (nonatomic, copy) NSString *rawMessage;//评论正文raw_message
@property (nonatomic, copy) NSString *htmlMessage;

@property (nonatomic, strong) NSDate *date;//评论发表时间createdAt
@property (nonatomic, strong) NSNumber *likes;//赞成票数likes
@property (nonatomic, strong) NSNumber *dislikes;
@property (nonatomic, copy) NSString *ipAddress;

@property (nonatomic, strong) NSNumber *commentID;//评论ID id
@property (nonatomic, strong) NSNumber *parentID;//父评论ID parent
@property (nonatomic, copy) NSString *mediaURL;//媒体(图片)url media/thumbnailURL
@property (nonatomic, strong) NSNumber *level;//父亲节点有几层,需计算

@end

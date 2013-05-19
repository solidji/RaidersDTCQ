//
// IADisquser.h
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
#import "IADisqusComment.h"
#import "IADisqusThread.h"
#import "IADisqusUser.h"
#import "AFOAuth2Client.h"

typedef void (^DisqusFetchCommentsSuccess)(NSArray *, NSDictionary *);

typedef void (^DisqusGetThreadIdSuccess)(NSNumber *);
typedef void (^DisqusPostCommentSuccess)(void);
typedef void (^DisqusFail)(NSError *);

typedef void (^DisqusLogin)(AFOAuthCredential *);
typedef void (^DisqusResponses)(NSDictionary *);

@class IADisqusComment;

@interface IADisquser : NSObject

@property (nonatomic, retain) AFOAuth2Client *afOauth2;
@property (nonatomic, retain) AFOAuthCredential *oCredential;
@property (nonatomic, copy) NSString *threadIdentifier, *oUsername, *oPassword;

- (id)initWithIdentifier:(NSString *)identifier;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(DisqusLogin)successBlock fail:(DisqusFail)failBlock;

- (void)getUsersDetails:(NSDictionary *)parameters success:(DisqusResponses)successBlock fail:(DisqusFail)failBlock;

- (void)getUsersFollowing:(NSDictionary *)parameters success:(DisqusResponses)successBlock fail:(DisqusFail)failBlock;

- (void)getUsersFollowers:(NSDictionary *)parameters success:(DisqusResponses)successBlock fail:(DisqusFail)failBlock;

- (void)getUsersActivity:(NSDictionary *)parameters success:(DisqusResponses)successBlock fail:(DisqusFail)failBlock;

- (void)getUsersPosts:(NSDictionary *)parameters success:(DisqusResponses)successBlock fail:(DisqusFail)failBlock;

#pragma mark - get active threads
+ (void)getActiveThreadsWithCursor:(NSString *)cursor user:(NSString *)user success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock;
#pragma mark - get top discussions
+ (void)getTopDiscussionsWithLimit:(NSString *)limit success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock;
#pragma mark - get top comments
+ (void)getTopCommentersWithCursor:(NSString *)cursor success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock;

#pragma mark - View comments
+ (void)getCommentsFromThreadID:(NSString *)threadID success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock;
+ (void)getCommentsFromThreadIdentifier:(NSString *)threadIdentifier success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock;
+ (void)getCommentsFromThreadLink:(NSString *)link success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock;
+ (void)getCommentsWithParameters:(NSDictionary *)parameters success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock;

#pragma mark - Post comments
+ (void)getThreadIdWithIdentifier:(NSString *)threadIdentifier success:(DisqusGetThreadIdSuccess)successBlock fail:(DisqusFail)failBlock;
+ (void)getThreadIdWithLink:(NSString *)link success:(DisqusGetThreadIdSuccess)successBlock fail:(DisqusFail)failBlock;
+ (void)postComment:(IADisqusComment *)comment success:(DisqusPostCommentSuccess)successBlock fail:(DisqusFail)failBlock;

@end

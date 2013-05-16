//
// IADisquser.m
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


#import "IADisquser.h"
#import "IADisqusConfig.h"
#import "AFHTTPClient.h"

@implementation IADisquser
@synthesize oCredential,threadIdentifier,afOauth2,oPassword,oUsername;

- (id)initWithIdentifier:(NSString *)identifier {
    if (self = [super init]) {
        self.threadIdentifier = identifier;
        self.oCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:identifier];
        self.oUsername = oCredential.username;
        if (![self.oUsername isEqualToString:nil]) {
            NSLog(@"I have a token! %@ %@", oCredential.accessToken,oUsername);
        }
    }
    return self;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
                  success:(DisqusLogin)successBlock fail:(DisqusFail)failBlock
{
    NSURL *url = [NSURL URLWithString:DISQUS_OAUTH_URL];
    AFOAuth2Client *oauthClient = [AFOAuth2Client clientWithBaseURL:url
                                                           clientID:DISQUS_API_PUBLIC
                                                             secret:DISQUS_API_SECRET];
    
    [oauthClient authenticateUsingOAuthWithPath:@"/api/oauth/2.0/access_token/"
                                       username:username
                                       password:password//kiueo_0903xerw3
                                          scope:@"read,write"
                                        success:^(AFOAuthCredential *credential) {
                                            NSLog(@"Get a new token! %@ %@ %@", credential.accessToken ,credential.username, credential.user_id);
                                            [AFOAuthCredential storeCredential:credential withIdentifier:oauthClient.serviceProviderIdentifier];
                                            self.threadIdentifier = oauthClient.serviceProviderIdentifier;
                                            self.oCredential = credential;
                                            self.oUsername = credential.username;
                                            self.oPassword = password;
                                            
                                            successBlock(credential);
                                        }
                                        failure:^(NSError *error) {
                                            NSLog(@"Error: %@", error);
                                            failBlock(error);
                                        }];
    self.afOauth2 = oauthClient;
}

- (void)getUsersDetails:(NSDictionary *)parameters success:(DisqusResponses)successBlock fail:(DisqusFail)failBlock{
    
    // make a http client for disqus
    AFHTTPClient *disqusClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:DISQUS_BASE_URL]];
    
    // make and send a get request
    [disqusClient getPath:@"users/details.json"
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      // fetch the json response to a dictionary
                      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                      // pass it to the block
                      successBlock(responseDictionary);
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      // pass error to the block
                      failBlock(error);
                  }];
}

- (void)getUsersFollowing:(NSDictionary *)parameters success:(DisqusResponses)successBlock fail:(DisqusFail)failBlock{
    
    // make a http client for disqus
    AFHTTPClient *disqusClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:DISQUS_BASE_URL]];
    
    // make and send a get request
    [disqusClient getPath:@"users/listFollowing.json"
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      // fetch the json response to a dictionary
                      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                      // pass it to the block
                      successBlock(responseDictionary);
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      // pass error to the block
                      failBlock(error);
                  }];
}


#pragma mark - View comments
+ (void)getCommentsWithParameters:(NSDictionary *)parameters success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock {
    // make a http client for disqus
    AFHTTPClient *disqusClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:DISQUS_BASE_URL]];
    
    // make and send a get request
    [disqusClient getPath:@"threads/listPosts.json"
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      // fetch the json response to a dictionary
                      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                      
                      // check the code (success is 0)
                      NSNumber *code = [responseDictionary objectForKey:@"code"];
                      
                      if ([code integerValue] != 0) {   // there's an error
                          NSString *errorMessage = @"Error on fetching comments from disqus";
                          
                          NSError *error = [NSError errorWithDomain:@"com.disqus.appgame" code:25 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorMessage, NSLocalizedDescriptionKey, nil]];
                          failBlock(error);
                      } else {  // fetching comments in json succeeded, now on to parsing
                          // mutable array for handling comments
                          NSMutableArray *comments = [NSMutableArray array];
                          NSDictionary *cursorDictionary = [responseDictionary objectForKey:@"cursor"];
                          // parse into array of comments
                          NSArray *commentsArray = [responseDictionary objectForKey:@"response"];
                          if ([commentsArray count] == 0) {
                              successBlock(nil,cursorDictionary);
                          } else {
                              // setting date format
                              NSDateFormatter *df = [[NSDateFormatter alloc] init];
                              NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                              [df setLocale:locale];
                              [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                              
                              // traverse the array, getting data for comments
                              for (NSDictionary *commentDictionary in commentsArray) {
                                  // for every comment, wrap them with IADisqusComment
                                  IADisqusComment *aDisqusComment = [[IADisqusComment alloc] init];
                                  
                                  aDisqusComment.authorName = [[commentDictionary objectForKey:@"author"] objectForKey:@"name"];
                                  aDisqusComment.authorAvatar = [[[[commentDictionary objectForKey:@"author"] objectForKey:@"avatar"] objectForKey:@"small"] objectForKey:@"cache"];

                                  aDisqusComment.likes = [commentDictionary objectForKey:@"likes"];
                                  aDisqusComment.rawMessage = [commentDictionary objectForKey:@"raw_message"];
                                  aDisqusComment.date = [df dateFromString:[[commentDictionary objectForKey:@"createdAt"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                                  aDisqusComment.commentID = [commentDictionary objectForKey:@"id"];
                                  aDisqusComment.parentID = [commentDictionary objectForKey:@"parent"];
                                  
                                  NSArray *media = [commentDictionary objectForKey:@"media"];
                                  if ([media count] > 0) {
                                      aDisqusComment.mediaURL = [[media objectAtIndex:0] objectForKey:@"thumbnailURL"];
                                  }

                                  aDisqusComment.threadID = [commentDictionary objectForKey:@"thread"];
                                  aDisqusComment.level = 0;
                                  // add the comment to the mutable array
                                  [comments addObject:aDisqusComment];
                              }
                              
                              // pass it to the block
                              successBlock(comments,cursorDictionary);
                          }
                      }
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      // pass error to the block
                      failBlock(error);
                  }];
}

+ (void)getCommentsFromThreadID:(NSString *)threadID success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock {
    // make the parameters dictionary 
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                DISQUS_API_SECRET, @"api_secret",
                                threadID, @"thread",
                                nil];
    
    // send the request
    [IADisquser getCommentsWithParameters:parameters success:successBlock fail:failBlock];
}

+ (void)getCommentsFromThreadIdentifier:(NSString *)threadIdentifier success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock {
    // make the parameters dictionary 
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                DISQUS_API_SECRET, @"api_secret",
                                DISQUS_FORUM_NAME, @"forum",
                                threadIdentifier, @"thread:ident",
                                nil];
    
    // send the request
    [IADisquser getCommentsWithParameters:parameters success:successBlock fail:failBlock];
}

+ (void)getCommentsFromThreadLink:(NSString *)link success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock {
    // make the parameters dictionary 
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                DISQUS_API_SECRET, @"api_secret",
                                DISQUS_FORUM_NAME, @"forum",
                                link, @"thread:link",
                                nil];
    
    // send the request
    [IADisquser getCommentsWithParameters:parameters success:successBlock fail:failBlock];
    
}

#pragma mark - Post comments
+ (void)getThreadIdParameters:(NSDictionary *)parameters success:(DisqusGetThreadIdSuccess)successBlock fail:(DisqusFail)failBlock {
    // make a http client for disqus
    AFHTTPClient *disqusClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:DISQUS_BASE_URL]];
    
    // fire the request
    [disqusClient getPath:@"threads/details.json"
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      // fetch the json response to a dictionary
                      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                      
                      // get the code
                      NSNumber *code = [responseDictionary objectForKey:@"code"];
                      
                      if ([code integerValue] != 0) {
                          // there's an error
                          NSString *errorMessage = @"Error on getting the thread ID from disqus";
                          
                          NSError *error = [NSError errorWithDomain:@"com.ikhsanassaat.disquser" code:26 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorMessage, NSLocalizedDescriptionKey, nil]];
                          failBlock(error);
                      } else {
                          // get the thread ID, pass it to the block
                          NSNumber *threadId = [[responseDictionary objectForKey:@"response"] objectForKey:@"id"];
                          successBlock(threadId);
                      }
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      failBlock(error);
                  }];
}

+ (void)getThreadIdWithIdentifier:(NSString *)threadIdentifier success:(DisqusGetThreadIdSuccess)successBlock fail:(DisqusFail)failBlock {
    // make parameters
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                DISQUS_API_SECRET, @"api_secret",
                                DISQUS_FORUM_NAME, @"forum",
                                threadIdentifier, @"thread:ident",
                                nil];
    
    // call general method
    [IADisquser getThreadIdParameters:parameters success:successBlock fail:failBlock];
}

+ (void)getThreadIdWithLink:(NSString *)link success:(DisqusGetThreadIdSuccess)successBlock fail:(DisqusFail)failBlock {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                DISQUS_API_SECRET, @"api_secret",
                                DISQUS_FORUM_NAME, @"forum",
                                link, @"thread:link",
                                nil];
    
    // call general method
    [IADisquser getThreadIdParameters:parameters success:successBlock fail:failBlock];
}

+ (void)postComment:(IADisqusComment *)comment success:(DisqusPostCommentSuccess)successBlock fail:(DisqusFail)failBlock {
    // make a disqus client 
    AFHTTPClient *disqusClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:DISQUS_BASE_URL]];
    [disqusClient setParameterEncoding:AFFormURLParameterEncoding];
    
    [disqusClient postPath:@"posts/create.json"
                parameters:@{@"api_secret" : DISQUS_API_SECRET, @"thread" : comment.threadID, @"author_name" : comment.authorName, @"author_email" : comment.authorEmail, @"message" : comment.rawMessage}
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       // fetch the json response to a dictionary
                       NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                       
                       // check the code (success is 0)
                       NSNumber *code = [responseDictionary objectForKey:@"code"];
                       
                       if ([code integerValue] != 0) {
                           // there's an error
                           NSString *errorMessage = @"Error on posting comment to disqus";
                           
                           NSError *error = [NSError errorWithDomain:@"com.ikhsanassaat.disquser" code:27 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorMessage, NSLocalizedDescriptionKey, nil]];
                           failBlock(error);
                       } else {
                           successBlock();
                       }
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       failBlock(error);
                   }];
}

#pragma mark - get top discussions
+ (void)getTopDiscussions:(NSDictionary *)parameters success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock {
    // make a http client for disqus
    AFHTTPClient *disqusClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:DISQUS_BASE_URL]];
    
    // make and send a get request
    [disqusClient getPath:@"threads/listPopular.json"
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      // fetch the json response to a dictionary
                      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                      
                      // check the code (success is 0)
                      NSNumber *code = [responseDictionary objectForKey:@"code"];
                      
                      if ([code integerValue] != 0) {   // there's an error
                          NSString *errorMessage = @"Error on fetching listPopular from disqus";
                          
                          NSError *error = [NSError errorWithDomain:@"com.ikhsanassaat.disquser" code:25 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorMessage, NSLocalizedDescriptionKey, nil]];
                          failBlock(error);
                      } else {  // fetching comments in json succeeded, now on to parsing
                          // mutable array for handling comments
                          NSMutableArray *threads = [NSMutableArray array];
                          NSDictionary *cursorDictionary = [responseDictionary objectForKey:@"cursor"];
                          // parse into array of comments
                          NSArray *commentsArray = [responseDictionary objectForKey:@"response"];
                          if ([commentsArray count] == 0) {
                              successBlock(nil,cursorDictionary);
                          } else {
                              // setting date format
                              NSDateFormatter *df = [[NSDateFormatter alloc] init];
                              NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                              [df setLocale:locale];
                              [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                              
                              // traverse the array, getting data for comments
                              for (NSDictionary *commentDictionary in commentsArray) {
                                  // for every thread, wrap them with IADisqusThread
                                  IADisqusThread *aDisqusThread = [[IADisqusThread alloc] init];
                                  
                                  aDisqusThread.authorID = [commentDictionary objectForKey:@"author"];
                                  aDisqusThread.category = [commentDictionary objectForKey:@"category"];
                                  aDisqusThread.date = [df dateFromString:[[commentDictionary objectForKey:@"createdAt"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                                  aDisqusThread.dislikes = [commentDictionary objectForKey:@"dislikes"];
                                  aDisqusThread.feed = [commentDictionary objectForKey:@"feed"];
                                  aDisqusThread.forumName = [commentDictionary objectForKey:@"forum"];
                                  aDisqusThread.threadID = [commentDictionary objectForKey:@"id"];
                                  aDisqusThread.threadIdentifier = [commentDictionary objectForKey:@"identifiers"];
                                  aDisqusThread.likes = [commentDictionary objectForKey:@"likes"];
                                  aDisqusThread.link = [commentDictionary objectForKey:@"link"];
                                  aDisqusThread.message = [commentDictionary objectForKey:@"message"];
                                  aDisqusThread.posts = [commentDictionary objectForKey:@"posts"];
                                  aDisqusThread.postsInInterval = [commentDictionary objectForKey:@"postsInInterval"];
                                  aDisqusThread.title = [commentDictionary objectForKey:@"title"];
                                  
                                  // add the comment to the mutable array
                                  [threads addObject:aDisqusThread];
                              }
                              
                              // release date formatting
                              
                              // pass it to the block
                              successBlock(threads,cursorDictionary);
                          }
                      }
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      // pass error to the block
                      failBlock(error);
                  }];
}

+ (void)getTopDiscussionsWithLimit:(NSString *)limit success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock {
    // make parameters
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                DISQUS_API_SECRET, @"api_secret",
                                DISQUS_FORUM_NAME, @"forum",
                                @"3d", @"interval",
                                limit, @"limit",
                                //threadIdentifier, @"thread:ident",
                                nil];
    
    // call general method
    [IADisquser getTopDiscussions:parameters success:successBlock fail:failBlock];
}

#pragma mark - get top comments
+ (void)getTopCommenters:(NSDictionary *)parameters success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock {
    // make a http client for disqus
    AFHTTPClient *disqusClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:DISQUS_BASE_URL]];
    
    // make and send a get request
    [disqusClient getPath:@"forums/listMostActiveUsers.json"
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      // fetch the json response to a dictionary
                      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                      
                      // check the code (success is 0)
                      NSNumber *code = [responseDictionary objectForKey:@"code"];
                      
                      if ([code integerValue] != 0) {   // there's an error
                          NSString *errorMessage = @"Error on fetching listPopular from disqus";
                          
                          NSError *error = [NSError errorWithDomain:@"com.ikhsanassaat.disquser" code:25 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorMessage, NSLocalizedDescriptionKey, nil]];
                          failBlock(error);
                      } else {  // fetching comments in json succeeded, now on to parsing
                          // mutable array for handling comments
                          NSMutableArray *users = [NSMutableArray array];
                          NSLog(@"cursor:%@",[[responseDictionary objectForKey:@"cursor"] objectForKey:@"next"]);
                          NSDictionary *cursorDictionary = [responseDictionary objectForKey:@"cursor"];
                          // parse into array of comments
                          NSArray *commentsArray = [responseDictionary objectForKey:@"response"];
                          if ([commentsArray count] == 0) {
                              successBlock(nil,cursorDictionary);
                          } else {
                              // setting date format
                              NSDateFormatter *df = [[NSDateFormatter alloc] init];
                              NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                              [df setLocale:locale];
                              [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                              
                              // traverse the array, getting data for comments
                              for (NSDictionary *commentDictionary in commentsArray) {
                                  // for every user, wrap them with IADisqusUser
                                  IADisqusUser *aDisqusUser = [[IADisqusUser alloc] init];
                                  
                                  aDisqusUser.username = [commentDictionary objectForKey:@"username"];
                                  aDisqusUser.about = [commentDictionary objectForKey:@"about"];
                                  aDisqusUser.name = [commentDictionary objectForKey:@"name"];
                                  aDisqusUser.numPosts = [commentDictionary objectForKey:@"numPosts"];
                                  aDisqusUser.url = [commentDictionary objectForKey:@"url"];
                                  aDisqusUser.profileUrl = [commentDictionary objectForKey:@"profileUrl"];
                                  aDisqusUser.reputation = [commentDictionary objectForKey:@"reputation"];
                                  aDisqusUser.location = [commentDictionary objectForKey:@"location"];
                                  aDisqusUser.joinedAt = [df dateFromString:[[commentDictionary objectForKey:@"joinedAt"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                                  aDisqusUser.userID = [commentDictionary objectForKey:@"id"];
                                  aDisqusUser.authorAvatar = [[commentDictionary objectForKey:@"avatar"] objectForKey:@"cache"];
                                  
                                  // add the comment to the mutable array
                                  [users addObject:aDisqusUser];
                              }
                              
                              // release date formatting
                              
                              // pass it to the block
                              successBlock(users,cursorDictionary);
                          }
                      }
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      // pass error to the block
                      failBlock(error);
                  }];
}

+ (void)getTopCommentersWithCursor:(NSString *)cursor success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock {
    // make parameters
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                DISQUS_API_SECRET, @"api_secret",
                                DISQUS_FORUM_NAME, @"forum",
                                cursor,@"cursor",
                                //threadIdentifier, @"thread:ident",
                                nil];
    
    // call general method
    [IADisquser getTopCommenters:parameters success:successBlock fail:failBlock];
}

#pragma mark - get active threads
+ (void)getActiveThreads:(NSDictionary *)parameters success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock {
    // make a http client for disqus
    AFHTTPClient *disqusClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:DISQUS_BASE_URL]];
    
    // make and send a get request
    [disqusClient getPath:@"users/listActiveThreads.json"
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      // fetch the json response to a dictionary
                      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                      
                      // check the code (success is 0)
                      NSNumber *code = [responseDictionary objectForKey:@"code"];
                      
                      if ([code integerValue] != 0) {   // there's an error
                          NSString *errorMessage = @"Error on fetching listActiveThreads from disqus";
                          
                          NSError *error = [NSError errorWithDomain:@"com.ikhsanassaat.disquser" code:25 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorMessage, NSLocalizedDescriptionKey, nil]];
                          failBlock(error);
                      } else {  // fetching comments in json succeeded, now on to parsing
                          // mutable array for handling comments
                          NSMutableArray *threads = [NSMutableArray array];
                          NSLog(@"cursor:%@",[[responseDictionary objectForKey:@"cursor"] objectForKey:@"next"]);
                          NSDictionary *cursorDictionary = [responseDictionary objectForKey:@"cursor"];
                          // parse into array of comments
                          NSArray *commentsArray = [responseDictionary objectForKey:@"response"];
                          if ([commentsArray count] == 0) {
                              successBlock(nil,cursorDictionary);
                          } else {
                              // setting date format
                              NSDateFormatter *df = [[NSDateFormatter alloc] init];
                              NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                              [df setLocale:locale];
                              [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                              
                              // traverse the array, getting data for comments
                              for (NSDictionary *commentDictionary in commentsArray) {
                                  // for every thread, wrap them with IADisqusThread
                                  IADisqusThread *aDisqusThread = [[IADisqusThread alloc] init];
                                  
                                  aDisqusThread.authorID = [commentDictionary objectForKey:@"author"];
                                  aDisqusThread.category = [commentDictionary objectForKey:@"category"];
                                  aDisqusThread.date = [df dateFromString:[[commentDictionary objectForKey:@"createdAt"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                                  aDisqusThread.dislikes = [commentDictionary objectForKey:@"dislikes"];
                                  aDisqusThread.feed = [commentDictionary objectForKey:@"feed"];
                                  aDisqusThread.forumName = [commentDictionary objectForKey:@"forum"];
                                  aDisqusThread.threadID = [commentDictionary objectForKey:@"id"];
                                  aDisqusThread.threadIdentifier = [commentDictionary objectForKey:@"identifiers"];
                                  aDisqusThread.likes = [commentDictionary objectForKey:@"likes"];
                                  aDisqusThread.link = [commentDictionary objectForKey:@"link"];
                                  aDisqusThread.message = [commentDictionary objectForKey:@"message"];
                                  aDisqusThread.posts = [commentDictionary objectForKey:@"posts"];
                                  aDisqusThread.postsInInterval = [commentDictionary objectForKey:@"postsInInterval"];
                                  aDisqusThread.title = [commentDictionary objectForKey:@"title"];
                                  
                                  // add the comment to the mutable array
                                  [threads addObject:aDisqusThread];
                              }
                              
                              // release date formatting
                              
                              // pass it to the block
                              successBlock(threads,cursorDictionary);
                          }
                      }
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      // pass error to the block
                      failBlock(error);
                  }];
}

+ (void)getActiveThreadsWithCursor:(NSString *)cursor user:(NSString *)user success:(DisqusFetchCommentsSuccess)successBlock fail:(DisqusFail)failBlock {
    // make parameters
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                DISQUS_API_SECRET, @"api_secret",
                                DISQUS_FORUM_NAME, @"forum",
                                user, @"user",
                                cursor, @"cursor",
                                //threadIdentifier, @"thread:ident",
                                nil];
    
    // call general method
    [IADisquser getActiveThreads:parameters success:successBlock fail:failBlock];
}

@end

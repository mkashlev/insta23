//
//  Api.h
//  Insta23
//
//  Created by Dmitry Kashlev on 11/5/17.
//  Copyright © 2017 Dmitry Kashlev. All rights reserved.
//

//login credentials:
// username: mobile23_tester4
// password: 23mobileTester23


#import <Foundation/Foundation.h>
#import "../Constants.h"


@interface Api : NSObject<NSURLSessionDelegate>
{
    NSString *accessToken;
    NSURLSession *session;
    NSDictionary *user;
    NSMutableArray *stream;
    NSMutableDictionary *likes;
}

+ (id)client;

- (NSURLRequest *)createAuthRequest;
- (NSString *)checkRequestForCallbackURL:(NSURLRequest *)req;

- (void)loadStreamFromApi;
- (NSArray *)getStream;
- (void)getLikesFor:(NSString *)post_id;
- (NSDictionary *)getLikes;
- (void)performLikeOn:(NSString *)post_id;
- (void)performUnlikeOn:(NSString *)post_id;

- (void)getUserInfoFromApi;
- (NSDictionary *)getUser;
- (BOOL)isLoggedIn;
- (void)logout;

@end

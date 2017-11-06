//
//  Api.m
//  Insta23
//
//  Created by Dmitry Kashlev on 11/5/17.
//  Copyright © 2017 Dmitry Kashlev. All rights reserved.
//

#import "Api.h"

@implementation Api

+ (id)client {
    static Api *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[self alloc] init];
    });
    return client;
}

- (id)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        stream = @[];
        likes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

//AUTH METHODS
- (NSURLRequest *)createAuthRequest {
    NSString *urlStr = [NSString stringWithFormat:@"%@/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token&scope=%@",BASE_URL,CLIENT_ID,REDIRECT_URI,INSTAGRAM_SCOPE];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    return request;
}

//handles callbacks from instagram login web view
- (NSString *)checkRequestForCallbackURL:(NSURLRequest *)req {
    NSString* urlString = [[req URL] absoluteString];
    
    // check, if auth was succesfull (check for redirect URL)
    if([urlString hasPrefix: REDIRECT_URI])
    {
        // extract and handle access token
        if ([urlString containsString:@"#access_token"]) {
            NSRange range = [urlString rangeOfString: @"#access_token="];
            accessToken = [urlString substringFromIndex: range.location+range.length];
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"InstagramAccessToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self getUserInfoFromApi];
            [self loadStreamFromApi];
            NSLog(@"Authenticated");
            return AUTH_AUTHENTICATED;
        } else if ([urlString containsString:@"code="]) {
            NSLog(@"Authorized");
            [self getUserInfoFromApi];
            [self loadStreamFromApi];
            return AUTH_AUTHORIZED;
        }
    }
    
    return @"";
}

//Checks if user has been logged in.
- (BOOL)isLoggedIn {
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:@"InstagramAccessToken"];
    return (accessToken != nil || (str != nil && ![str isEqualToString:@""]));
}

//perform logout
- (void)logout {
    [session resetWithCompletionHandler:^{
        //
    }];
    accessToken = nil;
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"InstagramAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    user = nil;
}


// Get Data from Instagram
- (NSDictionary *)getUser {
    return user;
}

- (void)getUserInfoFromApi {
    //May not be needed
    //api.instagram.com/v1/users/self/?access_token=ACCESS-TOKEN
    if ([self isLoggedIn]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@/v1/users/self/?access_token=%@",BASE_URL,accessToken];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPMethod:@"GET"];
        NSURLSessionDataTask *streamTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                // Success
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSError *jsonError;
                    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    
                    if (jsonError) {
                        // Error Parsing JSON
                        NSLog(@"USERINFO: error parsing json");
                        
                    } else {
                        // Success Parsing JSON
                        user = (NSDictionary *)[jsonResponse objectForKey:@"data"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NC_USER_INFO_LOADED_SIGNAL object:nil];
                    }
                }  else {
                    //Web server is returning an error
                    NSLog(@"USERINFO: error from api");
                }
            } else {
                // Fail
                NSLog(@"USERINFO: error : %@", error.description);
            }
        }];
        
        [streamTask resume];
    }
}

//Load all recent media for logged in user from Instagram API
- (void)loadStreamFromApi {
    //api.instagram.com/v1/users/self/media/recent/?access_token=ACCESS-TOKEN
    NSLog(@"LOAD STREAM FROM API");
    if ([self isLoggedIn]) {
        NSLog(@"LOAD STREAM FROM API: ISLOGGEDIN");
        NSString *urlStr = [NSString stringWithFormat:@"%@/v1/users/self/media/recent/?access_token=%@",BASE_URL,accessToken];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPMethod:@"GET"];
        NSURLSessionDataTask *streamTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                // Success
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSError *jsonError;
                    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    
                    if (jsonError) {
                        // Error Parsing JSON
                        NSLog(@"STREAM: error parsing json");
                        
                    } else {
                        // Success Parsing JSON
                        int code = [[[jsonResponse objectForKey:@"meta"] objectForKey:@"code"] intValue];
                        if (code == 200) {
                            stream = (NSArray *)[jsonResponse objectForKey:@"data"];
                            
                            //Need to collect likes too
                            for (NSDictionary *itm in stream) {
                                NSString *itmId = [itm objectForKey:@"id"];
                                [self getLikesFor:itmId];
                            }
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:NC_STREAM_LOADED_SIGNAL object:nil];
                        } else {
                            if ([[[jsonResponse objectForKey:@"meta"] objectForKey:@"error_type"] isEqualToString:@"OAuthAccessTokenException"]) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:NC_LOGOUT_SIGNAL object:nil];
                            }
                        }
                    }
                }  else {
                    //Web server is returning an error
                    NSLog(@"STREAM: error from api");
                }
            } else {
                // Fail
                NSLog(@"STREAM: error : %@", error.description);
            }
        }];
        [streamTask resume];
    }
}
- (NSArray *)getStream {
    return stream;
}

- (void)getLikesFor:(NSString *)post_id {
    if ([self isLoggedIn]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@/v1/media/%@/likes?access_token=%@",BASE_URL,post_id,accessToken];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPMethod:@"GET"];
        NSURLSessionDataTask *streamTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                // Success
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSError *jsonError;
                    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    NSLog(@"%@",jsonResponse);
                    if (jsonError) {
                        // Error Parsing JSON
                        NSLog(@"GETLIKES: error parsing json");
                        
                    } else {
                        // Success Parsing JSON
                        NSArray *l = (NSArray *)[jsonResponse objectForKey:@"data"];
                        [likes setObject:l forKey:post_id];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NC_LIKES_LOADED_SIGNAL object:nil userInfo:@{@"media_id": post_id}];
                        NSLog(@"LIKES LOADED FROM API");
                    }
                }  else {
                    //Web server is returning an error
                    NSLog(@"GETLIKES: error from api");
                }
            } else {
                // Fail
                NSLog(@"GETLIKES: error : %@", error.description);
            }
        }];
        [streamTask resume];
    }
}

- (NSDictionary *)getLikes {
    return likes;
}


//Execute Like on a selected post
- (void)performLikeOn:(NSString *)post_id {
    //POST api.instagram.com/v1/media/{media-id}/likes
    NSLog(@"performing like on %@",post_id);
    if ([self isLoggedIn]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@/v1/media/%@/likes?access_token=%@",BASE_URL,post_id,accessToken];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];

        [request setHTTPMethod:@"POST"];
        NSString *postString = [NSString stringWithFormat:@"access_token=%@",accessToken];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLSessionDataTask *streamTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                // Success
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSError *jsonError;
                    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    NSLog(@"%@",jsonResponse);
                    if (jsonError) {
                        // Error Parsing JSON
                        NSLog(@"PERFORMLIKE: error parsing json");
                        
                    } else {
                        // Success Parsing JSON
                        NSString *code = [[jsonResponse objectForKey:@"meta"] objectForKey:@"code"];
                        if (code && ([code intValue] == 200)) {
                            //Reload like list for this media post
                            [self getLikesFor:post_id];
                        }
                    }
                }  else {
                    //Web server is returning an error
                    NSLog(@"PERFORMLIKE: error from api");
                }
            } else {
                // Fail
                NSLog(@"PERFORMLIKE: error : %@", error.description);
            }
        }];
        [streamTask resume];
    }
}
//Execute unlike on a selected post
- (void)performUnlikeOn:(NSString *)post_id {
    //DEL api.instagram.com/v1/media/{media-id}/likes
    NSLog(@"performing unlike on %@",post_id);
    if ([self isLoggedIn]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@/v1/media/%@/likes?access_token=%@",BASE_URL,post_id,accessToken];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [request setHTTPMethod:@"DELETE"];
        NSURLSessionDataTask *streamTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                // Success
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSError *jsonError;
                    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    NSLog(@"%@",jsonResponse);
                    if (jsonError) {
                        // Error Parsing JSON
                        NSLog(@"PERFORM UNLIKE: error parsing json - %@",jsonError);
                        
                    } else {
                        // Success Parsing JSON
                        NSString *code = [[jsonResponse objectForKey:@"meta"] objectForKey:@"code"];
                        if (code && ([code intValue] == 200)) {
                            //Reload like list for this media post
                            [self getLikesFor:post_id];
                        }
                    }
                }  else {
                    //Web server is returning an error
                    NSLog(@"PERFORM UNLIKE: error from api");
                }
            } else {
                // Fail
                NSLog(@"PERFORM UNLIKE: error : %@", error.description);
            }
        }];
        [streamTask resume];
    }
}

//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
//    NSLog(@"did receive challenge");
////    NSLog(@"%@",session.);
//}



@end

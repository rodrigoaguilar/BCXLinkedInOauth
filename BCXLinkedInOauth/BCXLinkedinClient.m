//
//  BCXLinkedinClient.m
//  GoogleOauth1Test
//
//  Created by Rodrigo Aguilar on 3/4/13.
//  Copyright (c) 2013 bNapkin. All rights reserved.
//

#import "BCXLinkedinClient.h"
#import "BCXOAuthViewControllerTouch.h"

static NSString *const kRequestTokenURLString = @"https://api.linkedin.com/uas/oauth/requestToken";
static NSString *const kAccessTokenURLString = @"https://api.linkedin.com/uas/oauth/accessToken";
static NSString *const kAuthorizeURLString = @"https://api.linkedin.com/uas/oauth/authorize";

@interface BCXLinkedinClient ()


@end

@implementation BCXLinkedinClient

+ (id)sharedClient
{
    static BCXLinkedinClient *_sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BCXLinkedinClient alloc] init];
    });
    return _sharedClient;
}

- (BOOL)isLinked
{
    return NO;
}

- (void)unLink
{

}

- (void)linkFromController:(UIViewController *)rootController completionHandler:(void (^)(NSError *error))completion
{
    [self unLink];
}

- (void)getPath:(NSString *)path
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure
{

}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(id responseObject))success
         failure:(void (^)(NSError *error))failure
{

}


@end

//
//  BCXLinkedinClient.h
//  GoogleOauth1Test
//
//  Created by Rodrigo Aguilar on 3/4/13.
//  Copyright (c) 2013 bNapkin. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kApiKey = @"KEY";
static NSString *const kSecretKey = @"SECRET";

static NSString *const kLinkedinKeychainItemName = @"NAME";
static NSString *const kCallbackURLString = @"CALLBACK"; // This URL does not need to be for an actual web page
static NSString *const kLinkedinScope = @"r_basicprofile rw_nus";

static NSString *const kRequestTokenURLString = @"https://api.linkedin.com/uas/oauth/requestToken";
static NSString *const kAccessTokenURLString = @"https://api.linkedin.com/uas/oauth/accessToken";
static NSString *const kUserLoginURLString = @"https://www.linkedin.com/uas/oauth/authorize";

@interface BCXLinkedinClient : NSObject

+ (id)sharedClient;
- (BOOL)isLinked;
- (void)unLink;
- (void)linkFromController:(UIViewController *)rootController
         completionHandler:(void (^)(NSError *error))completion;

- (void)getPath:(NSString *)path
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(id responseObject))success
         failure:(void (^)(NSError *error))failure;

@end

//
//  BCXLinkedinClient.h
//  GoogleOauth1Test
//
//  Created by Rodrigo Aguilar on 3/4/13.
//  Copyright (c) 2013 bNapkin. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kApiKey = @"nopumdr4h1i5";
static NSString *const kSecretKey = @"W2XrBYinWGfZ6WZV";

static NSString *const kLinkedinKeychainItemName = @"bContext: Linkedin";
static NSString *const kCallbackURLString = @"bcontext-linkedin://success"; // This URL does not need to be for an actual web page

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
//
//  BCXLinkedinClient.m
//  GoogleOauth1Test
//
//  Created by Rodrigo Aguilar on 3/4/13.
//  Copyright (c) 2013 bNapkin. All rights reserved.
//

#import "BCXLinkedinClient.h"
#import "BCXOAuthViewControllerTouch.h"

#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"

static NSString *const kRequestTokenURLString = @"https://api.linkedin.com/uas/oauth/requestToken";
static NSString *const kAccessTokenURLString = @"https://api.linkedin.com/uas/oauth/accessToken";
static NSString *const kUserLoginURLString = @"https://www.linkedin.com/uas/oauth/authorize";

typedef void (^linkFromControllerCompletion)(NSError *error);

@interface BCXLinkedinClient ()

@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, strong) OAToken *requestToken;
@property (nonatomic, copy) linkFromControllerCompletion linkCompletion;

@end

@implementation BCXLinkedinClient

- (OAConsumer *)consumer
{
    if (!_consumer) {
        _consumer = [[OAConsumer alloc] initWithKey:kApiKey secret:kSecretKey realm:@"http://api.linkedin.com/"];
    }
    return _consumer;
}

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
    self.linkCompletion = completion;
    [self requestTokenFromProvider];
}

// OAuth step 1a:
//
// The first step in the the OAuth process to make a request for a "request token".
- (void)requestTokenFromProvider
{
    NSURL *requestTokenURL = [NSURL URLWithString:kRequestTokenURLString];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:requestTokenURL
                                                                   consumer:self.consumer
                                                                      token:nil
                                                                   callback:kCallbackURLString
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    OARequestParameter *nameParam = [[OARequestParameter alloc] initWithName:@"scope"
                                                                       value:@"r_basicprofile+rw_nus"];
    [request setParameters:@[nameParam]];
    OARequestParameter * scopeParameter=[OARequestParameter requestParameter:@"scope" value:@"r_fullprofile rw_nus"];
    [request setParameters:@[scopeParameter]];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenResult:didFinish:)
                  didFailSelector:@selector(requestTokenResult:didFail:)];
}

#pragma mark Request Token Callbacks
// OAuth step 1b:
//
// When this method is called it means we have successfully received a request token.

- (void)requestTokenResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    if (ticket.didSucceed == NO) {
        [self reportRequestTokenError];
        return;
    }
    
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    self.requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    NSLog(@"success!");
}

- (void)requestTokenResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"Error getting token: %@",[error description]);
    [self reportRequestTokenError];
}

- (void)reportRequestTokenError
{
    if (self.linkCompletion) {
        NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                    code:404
                                                userInfo:@{NSLocalizedDescriptionKey: @"Can't get token"}];
        self.linkCompletion(error);
    }
}

#pragma mark ------------


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

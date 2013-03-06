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
#import "JSONKit.h"

typedef void (^linkFromControllerCompletion)(NSError *error);
typedef void (^successApiCall)(id responseObject);
typedef void (^failureApicall)(NSError *error);

@interface BCXLinkedinClient () <BCXOAuthViewControllerTouchDelegate>

@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, strong) OAToken *requestToken;
@property (nonatomic, strong) OAToken *accessToken;
@property (nonatomic, copy) linkFromControllerCompletion linkCompletion;
@property (nonatomic, copy) successApiCall success;
@property (nonatomic, copy) failureApicall failure;
@property (nonatomic, weak) UIViewController *linkRootController;

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
        _sharedClient.accessToken = [BCXLinkedinClient retrieveTokenWithIdentifier:kLinkedinKeychainItemName];
    });
    return _sharedClient;
}

- (BOOL)isLinked
{
    return _accessToken != nil;
}

- (void)unLink
{
    [BCXLinkedinClient deleteTokenWithIdentifier:kLinkedinKeychainItemName];
    self.accessToken = nil;
}

- (void)linkFromController:(UIViewController *)rootController completionHandler:(void (^)(NSError *error))completion
{
    [self unLink];
    self.linkCompletion = completion;
    self.linkRootController = rootController;
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
                                                                       value:kLinkedinScope];
    [request setParameters:@[nameParam]];
    OARequestParameter * scopeParameter=[OARequestParameter requestParameter:@"scope"
                                                                       value:kLinkedinScope];
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
    [self allowUserToLogin];
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

#pragma mark Allow User to Login
// OAuth step 2:
//
// Show the user a browser displaying the LinkedIn login page.

- (void)allowUserToLogin
{
    NSString *userLoginURLStringWithToken = [NSString stringWithFormat:@"%@?oauth_token=%@",kUserLoginURLString, self.requestToken.key];
    NSURL *userLoginURL = [NSURL URLWithString:userLoginURLStringWithToken];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:userLoginURL];
    BCXOAuthViewControllerTouch *loginViewController = [[BCXOAuthViewControllerTouch alloc] initWithRequest:request];
    loginViewController.cancelCompletionBlock = self.linkCompletion;
    loginViewController.delegate = self;
    [self.linkRootController presentViewController:loginViewController animated:YES completion:nil];
}

#pragma mark BCXOAuthViewControllerTouchDelegate

-(void)bCXOAuthViewControllerTouch:(BCXOAuthViewControllerTouch *)viewController successWithURL:(NSURL *)url
{
    [self.requestToken setVerifierWithUrl:url];
    [self accessTokenFromProvider];
}

#pragma mark Access Token
// OAuth step 4:
//
- (void)accessTokenFromProvider
{
    NSURL *accessTokenURL = [NSURL URLWithString:kAccessTokenURLString];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:accessTokenURL
                                                                   consumer:self.consumer
                                                                      token:self.requestToken
                                                                   callback:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenResult:didFinish:)
                  didFailSelector:@selector(accessTokenResult:didFail:)];
}

- (void)accessTokenResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSError *error;
    BOOL problem = ([responseBody rangeOfString:@"oauth_problem"].location != NSNotFound);
    if ( problem ) {
        error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                           code:404
                                       userInfo:@{NSLocalizedDescriptionKey: @"Request access token failed.", @"responseBody" : responseBody}];
    } else {
        self.accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        [BCXLinkedinClient deleteTokenWithIdentifier:kLinkedinKeychainItemName];
        [BCXLinkedinClient storeToken:self.accessToken withIdentifier:kLinkedinKeychainItemName];
    }
    // Notify parent and close this view
    if (self.linkCompletion) {
        self.linkCompletion(error);
    }
}

- (void)accessTokenResult:(OAServiceTicket *)ticket didFail:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    NSError *error =  [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                 code:404
                                             userInfo:@{NSLocalizedDescriptionKey: @"Request access token failed.",@"responseBody" : responseBody}];
    if (self.linkCompletion) {
        self.linkCompletion(error);
    }
}

#pragma mark Get API Calls


- (void)getPath:(NSString *)path
        success:(successApiCall)success
        failure:(failureApicall)failure
{
    self.success = success;
    self.failure = failure;
    NSURL *url = [NSURL URLWithString:path];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.consumer
                                                                      token:self.accessToken
                                                                   callback:nil
                                                          signatureProvider:nil];
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(getApiCallResult:didFinish:)
                  didFailSelector:@selector(getApiCallResult:didFail:)];
}

- (void)getApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSDictionary *profile = [responseBody objectFromJSONString];
    
    if (profile) {
        if (self.success) {
            self.success(profile);
        }
    } else {
        if (self.failure) {
            NSError *error =  [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                         code:404
                                                     userInfo:@{NSLocalizedDescriptionKey: @"Error getting path",@"responseBody" : responseBody}];
            self.failure(error);
        }
    }
}

- (void)getApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    if (self.failure) {
        NSError *errorFromData =  [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                     code:404
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Error getting path",@"response" : [error description]}];
        self.failure(errorFromData);
    }
}

#pragma mark Post Api Calls

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(successApiCall)success
         failure:(failureApicall)failure
{
    self.success = success;
    self.failure = failure;
    NSURL *url = [NSURL URLWithString:path];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.consumer
                                                                      token:self.accessToken
                                                                   callback:nil
                                                          signatureProvider:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    NSString *paramsString = [parameters JSONString];
    [request setHTTPBodyWithString:paramsString];
	[request setHTTPMethod:@"POST"];
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(postApiCallResult:didFinish:)
                  didFailSelector:@selector(postApiCallResult:didFail:)];
}

- (void)postApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSDictionary *response = [responseBody objectFromJSONString];
    if (response) {
        if(self.success) {
            self.success(response);
        }
    } else {
        if (self.failure) {
            NSError *error =  [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                         code:404
                                                     userInfo:@{NSLocalizedDescriptionKey: @"Error posting path",@"responseBody" : responseBody}];
            self.failure(error);
        }
    }
}

- (void)postApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    if (self.failure) {
        NSError *errorFromData =  [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                             code:404
                                                         userInfo:@{NSLocalizedDescriptionKey: @"Error posting path",@"response" : [error description]}];
        self.failure(errorFromData);
    }
}

#pragma mark Token Management

NSString * const kBCXAuthCredentialServiceName = @"BCXAuthCredentialService";

static NSMutableDictionary * BCXKeychainQueryDictionaryWithIdentifier(NSString *identifier) {
    NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:(__bridge id)kSecClassGenericPassword, kSecClass, kBCXAuthCredentialServiceName, kSecAttrService, nil];
    [queryDictionary setValue:identifier forKey:(__bridge id)kSecAttrAccount];
	
    return queryDictionary;
}

+ (BOOL)storeToken:(OAToken *)token
    withIdentifier:(NSString *)identifier
{
    NSMutableDictionary *queryDictionary = BCXKeychainQueryDictionaryWithIdentifier(identifier);
	
    if (token == nil) {
        return [self deleteTokenWithIdentifier:identifier];
    }
	
    NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionary];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:token];
    [updateDictionary setObject:data forKey:(__bridge id)kSecValueData];
	
    OSStatus status;
    BOOL exists = ([self retrieveTokenWithIdentifier:identifier] != nil);
	
    if (exists) {
        status = SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)updateDictionary);
    } else {
        [queryDictionary addEntriesFromDictionary:updateDictionary];
        status = SecItemAdd((__bridge CFDictionaryRef)queryDictionary, NULL);
    }
	
    if (status != errSecSuccess) {
        NSLog(@"Unable to %@ credential with identifier \"%@\" (Error %li)", exists ? @"update" : @"add", identifier, status);
    }
	
    return (status == errSecSuccess);
}

+ (BOOL)deleteTokenWithIdentifier:(NSString *)identifier
{
    NSMutableDictionary *queryDictionary = BCXKeychainQueryDictionaryWithIdentifier(identifier);
	
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)queryDictionary);
	
    if (status != errSecSuccess) {
        NSLog(@"Unable to delete credential with identifier \"%@\" (Error %li)", identifier, status);
    }
	
    return (status == errSecSuccess);
}

+ (OAToken *)retrieveTokenWithIdentifier:(NSString *)identifier
{
    NSMutableDictionary *queryDictionary = BCXKeychainQueryDictionaryWithIdentifier(identifier);
    [queryDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [queryDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	
    CFDataRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&result);
	
    if (status != errSecSuccess) {
        NSLog(@"Unable to fetch credential with identifier \"%@\" (Error %li)", identifier, status);
        return nil;
    }
	
    NSData *data = (__bridge NSData *)result;
    OAToken *token = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
    return token;
}

@end

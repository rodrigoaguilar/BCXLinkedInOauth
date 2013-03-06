//
//  BCXOAuthViewControllerTouch.m
//  GoogleOauth1Test
//
//  Created by Rodrigo Aguilar on 3/4/13.
//  Copyright (c) 2013 bNapkin. All rights reserved.
//

#import "BCXOAuthViewControllerTouch.h"

@interface BCXOAuthViewControllerTouch ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *initialActivityIndicator;

@end

@implementation BCXOAuthViewControllerTouch

+ (NSString *)authNibName
{
    return @"BCXOAuthViewControllerTouch";
}

- (IBAction)cancel:(UIBarButtonItem *)sender
{
    //[self cancelSigningIn];
    if (self.cancelCompletionBlock) {
        NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                    code:NSUserCancelledError
                                                userInfo:@{NSLocalizedDescriptionKey: @"User cancelled operation"}];
        self.cancelCompletionBlock(error);
    }
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //[super webViewDidStartLoad:webView];
    [self.activityIndicator startAnimating];
    if ([self.initialActivityIndicator isAnimating]) {
        [self.initialActivityIndicator stopAnimating];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //[super webViewDidFinishLoad:webView];
    [self.activityIndicator stopAnimating];
}


@end

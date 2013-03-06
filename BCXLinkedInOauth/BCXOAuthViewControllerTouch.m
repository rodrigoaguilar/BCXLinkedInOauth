//
//  BCXOAuthViewControllerTouch.m
//  GoogleOauth1Test
//
//  Created by Rodrigo Aguilar on 3/4/13.
//  Copyright (c) 2013 bNapkin. All rights reserved.
//

#import "BCXOAuthViewControllerTouch.h"
#import "BCXLinkedinClient.h"

@interface BCXOAuthViewControllerTouch ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *initialActivityIndicator;
@property (nonatomic, strong) NSURLRequest *request;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BCXOAuthViewControllerTouch

- (id)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    
    if (self) {
        _request = request;
    }
    return self;
}

-(void)viewDidLoad
{
    if (self.request) {
        [self.webView loadRequest:self.request];
    }
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

#pragma mark WebViewDelegate

//
// OAuth step 3:
//
// This method is called when our webView browser loads a URL, this happens 3 times:
//
//      a) Our own [webView loadRequest] message sends the user to the LinkedIn login page.
//
//      b) The user types in their username/password and presses 'OK', this will submit
//         their credentials to LinkedIn
//
//      c) LinkedIn responds to the submit request by redirecting the browser to our callback URL
//         If the user approves they also add two parameters to the callback URL: oauth_token and oauth_verifier.
//         If the user does not allow access the parameter user_refused is returned.
//  We only need to handle case (c) to extract the oauth_verifier value

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = request.URL;
	NSString *urlString = url.absoluteString;
    
    BOOL requestForCallbackURL = ([urlString rangeOfString:kCallbackURLString].location != NSNotFound);
    if ( requestForCallbackURL )
    {
        BOOL userAllowedAccess = ([urlString rangeOfString:@"user_refused"].location == NSNotFound);
        if ( userAllowedAccess )
        {
            [self.delegate bCXOAuthViewControllerTouch:self successWithURL:url];
        }
        else
        {
            // User refused to allow our app access
            // Notify parent and close this view
            [self cancel:nil];
        }
    }
	return YES;
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

//
//  BCXOAuthViewControllerTouch.h
//  GoogleOauth1Test
//
//  Created by Rodrigo Aguilar on 3/4/13.
//  Copyright (c) 2013 bNapkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BCXOAuthViewControllerTouchDelegate;

@interface BCXOAuthViewControllerTouch : UIViewController

@property (nonatomic, copy) void (^cancelCompletionBlock)(NSError *error);
@property (nonatomic, assign) id<BCXOAuthViewControllerTouchDelegate> delegate;

- (id)initWithRequest:(NSURLRequest *)request;

@end


@protocol BCXOAuthViewControllerTouchDelegate <NSObject>

-(void)bCXOAuthViewControllerTouch:(BCXOAuthViewControllerTouch *)viewController successWithURL:(NSURL *)url;

@end
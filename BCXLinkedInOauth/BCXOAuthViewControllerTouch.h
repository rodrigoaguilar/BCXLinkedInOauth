//
//  BCXOAuthViewControllerTouch.h
//  GoogleOauth1Test
//
//  Created by Rodrigo Aguilar on 3/4/13.
//  Copyright (c) 2013 bNapkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCXOAuthViewControllerTouch : UIViewController

@property (nonatomic, copy) void (^cancelCompletionBlock)(NSError *error);


@end

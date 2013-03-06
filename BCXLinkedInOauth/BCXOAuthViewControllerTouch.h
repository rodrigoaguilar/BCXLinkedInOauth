//
//  BCXOAuthViewControllerTouch.h
//  GoogleOauth1Test
//
//  Created by Rodrigo Aguilar on 3/4/13.
//  Copyright (c) 2013 bNapkin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^linkFromControllerCompletion)(NSError *error);

@interface BCXOAuthViewControllerTouch : UIViewController

@property (nonatomic, copy) linkFromControllerCompletion cancelCompletionBlock;


@end

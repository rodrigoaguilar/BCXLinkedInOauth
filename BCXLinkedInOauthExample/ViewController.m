//
//  ViewController.m
//  GoogleOauth1Test
//
//  Created by Rodrigo Aguilar on 3/4/13.
//  Copyright (c) 2013 bNapkin. All rights reserved.
//

#import "ViewController.h"
#import "BCXLinkedinClient.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *linkButton;
@property (weak, nonatomic) IBOutlet UIButton *apiCallButton;
@property (weak, nonatomic) IBOutlet UITextField *statusTextField;
@property (weak, nonatomic) IBOutlet UIButton *postStatusButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self updateUI];
}

- (void)updateUI
{
    if ([[BCXLinkedinClient sharedClient] isLinked]) {
        self.apiCallButton.enabled = YES;
        self.statusTextField.enabled = YES;
        self.postStatusButton.enabled = YES;
        [self.linkButton setTitle:@"unLink" forState:UIControlStateNormal];
    } else {
        self.apiCallButton.enabled = NO;
        self.statusTextField.enabled = NO;
        self.postStatusButton.enabled = NO;
        [self.linkButton setTitle:@"Link" forState:UIControlStateNormal];
    }
}


- (IBAction)link:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"Link"]) {
        [[BCXLinkedinClient sharedClient] linkFromController:self completionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Error %@", error);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            [self updateUI];
        }];
    } else {
        [[BCXLinkedinClient sharedClient] unLink];
        [self updateUI];
    }
}


- (IBAction)apiCall:(id)sender
{
    [[BCXLinkedinClient sharedClient] getPath:@"http://api.linkedin.com/v1/people/~:(id,first-name,last-name,headline)"
                                      success:^(id responseObject) {
                                          NSLog(@"%@", responseObject);
                                      }
                                      failure:^(NSError *error) {
                                          NSLog(@"error : %@", [error localizedDescription]);
                                      }];
}
- (IBAction)postApiCall:(id)sender
{
    NSDictionary *params = @{@"comment": self.statusTextField.text, @"visibility" : @{@"code": @"anyone"} };
    
    [[BCXLinkedinClient sharedClient] postPath:@"http://api.linkedin.com/v1/people/~/shares"
                                    parameters:params
                                       success:^(id responseObject) {
                                           [self.statusTextField resignFirstResponder];
                                           NSLog(@"%@", responseObject);
                                       } failure:^(NSError *error) {
                                           [self.statusTextField resignFirstResponder];
                                           NSLog(@"error : %@", error);
                                       }];
}

@end

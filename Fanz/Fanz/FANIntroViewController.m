//
//  FANIntroViewController.m
//  Fanz
//
//  Created by Ankur Oberoi on 4/27/13.
//  Copyright (c) 2013 Ankur Oberoi. All rights reserved.
//

#import "FANIntroViewController.h"
#import <FacebookSDK/Facebook.h>
#import "FANAppDelegate.h"

@interface FANIntroViewController ()

- (void)handleOpenSessionCompletionWithSession:(FBSession *)session state:(FBSessionState)status error:(NSError *)error;

@end

@implementation FANIntroViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    // assign a background image
    self.backgroundImageView.image = [[UIImage imageNamed:@"intro_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(24.0, 24.0, 24.0, 24.0)
                                                                                              resizingMode:UIImageResizingModeStretch];
    
    if (![FBSession activeSession].isOpen) {
    
        if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
            [FBSession openActiveSessionWithReadPermissions:@[@"email"]
                                               allowLoginUI:NO
                                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                [self handleOpenSessionCompletionWithSession:session state:status error:error];
            }];
        }
    } else {
        [self handleOpenSessionCompletionWithSession:[FBSession activeSession] state:[FBSession activeSession].state error:nil];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginPressed:(id)sender {
    
    if ([FBSession activeSession].isOpen) {
        NSLog(@"facebook session was already logged in");
        return;
    } else {
        // if the session isn't open, let's open it now and present the login UX to the user
        [FBSession openActiveSessionWithReadPermissions:@[@"email"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [self handleOpenSessionCompletionWithSession:session state:status error:error];
        }];
    }
}

- (void)handleOpenSessionCompletionWithSession:(FBSession *)session state:(FBSessionState)status error:(NSError *)error
{
    if (error) {
        NSLog(@"error after opening facebook session: %@", error.description);
        return;
    }
    
    switch (status) {
        case FBSessionStateOpen:
            [self performSegueWithIdentifier:@"loggedIn" sender:self];
            break;
        case FBSessionStateClosedLoginFailed:
            NSLog(@"facebook session login failed");
            break;
        default:
            NSLog(@"facebook session transitioned into some other state");
            break;
    }
}

@end

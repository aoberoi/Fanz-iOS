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

- (void)updateView;

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
    
    //[self updateView];
    
    //FANAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (![FBSession activeSession].isOpen) {
        // create a fresh session object
        //appDelegate.facebookSession = [[FBSession alloc] init];
    
        if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            //[appDelegate.facebookSession openWithCompletionHandler:^(FBSession *session,
            //                                                 FBSessionState status,
            //                                                 NSError *error) {
            [FBSession openActiveSessionWithReadPermissions:@[@"email"]
                                               allowLoginUI:NO
                                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                // we recurse here, in order to update buttons and labels
                [self updateView];
            }];
        }
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginPressed:(id)sender {
    //NSArray *permissions = [NSArray arrayWithObjects:@"email", nil];
    
    //FANAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if ([FBSession activeSession].isOpen) {
        NSLog(@"facebook session was already logged in");
        return;
    } else {
        if ([FBSession activeSession].state != FBSessionStateCreated) {
            // Create a new, logged out session.
            //appDelegate.facebookSession = [[FBSession alloc] init];
             NSLog(@"facebook session is cached on button press but wasn't on load");
        }
        
        // if the session isn't open, let's open it now and present the login UX to the user
        //[appDelegate.facebookSession openWithCompletionHandler:^(FBSession *session,
        //                                                 FBSessionState status,
        //                                                 NSError *error) {
        [FBSession openActiveSessionWithReadPermissions:@[@"email"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            
            if (error) {
                NSLog(@"error after opening facebook session: %@", error.description);
                return;
            }
            
            NSLog(@"facebook session state: %d", status);
            
            // and here we make sure to update our UX according to the new session state
            [self updateView];
        }];
    }
    
//    [FBSession openActiveSessionWithReadPermissions:permissions
//                                       allowLoginUI:YES
//                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//                                      appDelegate.facebookSession = session;
//                                      /* handle success + failure in block */
//                                      NSLog(@"Login success");
//                                  }];
}

- (void) updateView
{
    //FANAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ([FBSession activeSession].isOpen) {
        NSLog(@"facebook session is open");
    } else {
        NSLog(@"facebook session is not open");
    }
}

@end

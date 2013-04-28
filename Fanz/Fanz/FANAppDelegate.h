//
//  FANAppDelegate.h
//  Fanz
//
//  Created by Ankur Oberoi on 4/27/13.
//  Copyright (c) 2013 Ankur Oberoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/Facebook.h>
#import "FANRoomChannelClient.h"

@interface FANAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *facebookSession;
@property (strong, nonatomic) FANRoomChannelClient *roomClient;

@end

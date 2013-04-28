//
//  FANFindGameViewController.h
//  Fanz
//
//  Created by Ankur Oberoi on 4/27/13.
//  Copyright (c) 2013 Ankur Oberoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GracenoteACR.h"


@interface FANFindGameViewController : UIViewController <IGnAcrResultDelegate, IGnAcrStatusDelegate, AVAudioSessionDelegate, GnAudioSourceDelegate> {
    
    // Gracenote Objects
    //GnSdkManager *gracenoteSdkManager;
    //GnUser *gracenoteUser;
    //GnACR *gracenoteAcr;
    //GnAudioSourceiOSMic *gracenoteAudioSource;
}

@property (strong) GnSdkManager *gracenoteSdkManager;
@property (strong) GnUser *gracenoteUser;
@property (strong) GnACR *gracenoteAcr;
@property (strong) GnAudioSourceiOSMic *gracenoteAudioSource;

@end

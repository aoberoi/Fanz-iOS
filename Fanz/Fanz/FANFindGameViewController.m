//
//  FANFindGameViewController.m
//  Fanz
//
//  Created by Ankur Oberoi on 4/27/13.
//  Copyright (c) 2013 Ankur Oberoi. All rights reserved.
//

/*
 username
 program_id (program.tui-program.tuitag)
 match_time (adjustedPosition)
 */

#import "FANFindGameViewController.h"

#define SAVED_USER_KEY_ACR @"savedUserACR"

@interface FANFindGameViewController ()

- (void)initManagerWithError:(NSError **)error;
- (void)initAcrUserWithError:(NSError **)error;

@end

@implementation FANFindGameViewController

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
    
    // As soon as we open up, start ACR
    [self listenForProgram];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)listenForProgram
{
    NSError *error = nil;
    
    [self initManagerWithError:&error];
    
    if (error){
        // [self updateResultMessage:error.localizedDescription];
        //[self updateStatusMessage:[NSString stringWithFormat:@"Initialization failure"]];
        NSLog(@"Failed to initialize Gracenote SDK Manager");
        return;
    }
    
    
    //NSString *versionMessage = [NSString stringWithFormat:@"ACR version %@", [mManager productVersion]];
    //[self updateStatusMessage:versionMessage];
    
    // reuse saved user or create a new one
    [self initAcrUserWithError:&error];
    
    if (error) {
        //[self updateStatusMessage:[NSString stringWithFormat:@"Invalid User"]];
        NSLog(@"Failed to initialize Gracenote ACR User");
        return;
    }
    
    // create ACR object with user
    self.gracenoteAcr = [[GnACR alloc] initWithUser:self.gracenoteUser
                                              error:&error];
    

    if (error) {
        //NSString *msg = [NSString stringWithFormat:@"ACR init ERROR: %@ (0x%x)", error.localizedDescription, error.code];
        //[self updateStatusMessage:msg];
        NSLog(@"Failed to initialize Gracenote ACR");
        return;
    }
    
    // set the delegates to receive status and results
    // this class implements the delegate protocols
    // IGnAcrResultDelegate, IGnAcrStatusDelegate
    // via delegate methods acrResultReady: and acrStatusReady:
    self.gracenoteAcr.statusDelegate = self;
    self.gracenoteAcr.resultDelegate = self;
    
    // set the Audio config on the ACR object
    GnAcrAudioConfig *config = [[GnAcrAudioConfig alloc] initWithAudioSourceType:GnAcrAudioSourceMic
                                                                      sampleRate:GnAcrAudioSampleRate44100
                                                                          format:GnAcrAudioSampleFormatPCM16
                                                                     numChannels:1];
    
    error = [self.gracenoteAcr audioInitWithAudioConfig:config];
    
    if (error) {
        //NSString *msg = [NSString stringWithFormat:@"Audio init ERROR: %@ (0x%x)", error.localizedDescription, error.code];
        //[self updateStatusMessage:msg];
        NSLog(@"Failed to initialize Gracenote Audio");
        return;
    }
    
    
    // Create the audio source with the same config used for the mACR object
    self.gracenoteAudioSource = [[GnAudioSourceiOSMic alloc] initWithAudioConfig:config];
    // specify the delegate object which will receive the audio data callback
    self.gracenoteAudioSource.audioDelegate = self;
    
    
    // Start the audio Source
    error = [self.gracenoteAudioSource start];
    if (error) {
        //NSString *msg = [NSString stringWithFormat:@"Source Start ERROR: %@ (0x%x)", error.localizedDescription, error.code];
        //[self updateStatusMessage:msg];
        NSLog(@"Failed to start Gracenote Audio Source");
        return;
    }
    
    
    //[self updateStatusMessage:@"ACR Start Success"];
    // ACR setup complete
    // Results and status will come via delegate callback (acrStatusReady and acrResultReady)
    
    
    // AVAudioSessionDelegate
    [[AVAudioSession sharedInstance] setDelegate:self];

}

#pragma mark - Audio Session Delegate methods

- (void)beginInterruption
{
    // respond to interruption (phone call, etc)
    // stop audio
    [self stopACR];
    // reset UI button
    //buttonACR.selected = NO;
    //[self updateStatusMessage:@"ACR Stopped due to audio interruption"];
    
}

-(void)endInterruption
{
    //    NSLog(@"endInterruption");
}

#pragma mark - Gracenote Audio Source Delegate methods

-(void)audioBytesReady:(void const * const)bytes length:(int)length
{
    // The GnAudioSourceiOSMic object pointed to by mSource will call this method when audio is available
    // from the input device. The application can then pass the audio into the GnAcr writeBytes to feed audio
    // to ACR, or use the audio otherwise, by copying to memory, file, etc. This audio can also be fed into
    // GnMusicID writeBytes to do a music query.
    
    // this callback is called from a background thread. It is important to not block this
    // callback for very long. It is advised to offload UI updates and expensive computations to the main thread.
    NSError *error = nil;
    error = [self.gracenoteAcr writeBytes:bytes length:length];
    if (error) {
        NSLog(@"audioBytesReady error: %@", error);
    }
    
}

#pragma mark - Gracenote ACR Status Delegate methods

// TODO: we may not need this, lets look up what these statuses actually mean

-(void)acrStatusReady:(GnAcrStatus*)status
{
    @autoreleasepool {
        // This status callback will be called periodically with status from the ACR subsystem
        // You can use these statuses as you like.
        
        // These callbacks may occur on threads other than the main thread.
        // Be careful not to block these callbacks for long periods of time.
        
        
        NSString *message = nil;
        BOOL doShowStatus = YES;
        
        switch (status.statusType) {
            case GnAcrStatusTypeSilent:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:SILENCE_KEY];
                message = [NSString stringWithFormat:@"Audio Silent %10.2f", status.value];
                break;
            case GnAcrStatusTypeSilentRatio:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:RATIO_KEY];
                message = [NSString stringWithFormat:@"Silent Ratio %10.3f", status.value];
                break;
            case GnAcrStatusTypeError:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:ERROR_KEY];
                message = [NSString stringWithFormat:@"ERROR %@ (0x%x)", [status.error localizedDescription], status.error.code];
                break;
            case GnAcrStatusTypeNoMatchMode:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:MODE_KEY];
                message = [NSString stringWithFormat:@"No Match Mode %10.0f secs between queries", status.value];
                break;
            case GnAcrStatusTypeConnecting:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:NETWORK_KEY];
                message = [NSString stringWithFormat:@"Connecting"];
                break;
            case GnAcrStatusTypeFingerprintGenerated:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:FP_KEY];
                message = [NSString stringWithFormat:@"Fingerprint Generated"];
                break;
            case GnAcrStatusTypeFingerprintStarted:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:FP_KEY];
                message = [NSString stringWithFormat:@"Fingerprint Started"];
                break;
            case GnAcrStatusTypeLocalLookupComplete:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:LOCAL_KEY];
                message = [NSString stringWithFormat:@"Local Lookup Complete"];
                break;
            case GnAcrStatusTypeMusic:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:NSM_KEY];
                message = [NSString stringWithFormat:@"Audio Music"];
                break;
            case GnAcrStatusTypeNetworkReceiving:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:NETWORK_KEY];
                message = [NSString stringWithFormat:@"Network Receiving"];
                break;
            case GnAcrStatusTypeNetworkSending:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:NETWORK_KEY];
                message = [NSString stringWithFormat:@"Network Sending"];
                break;
            case GnAcrStatusTypeNoise:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:NSM_KEY];
                message = [NSString stringWithFormat:@"Audio Noise"];
                break;
            case GnAcrStatusTypeSpeech:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:NSM_KEY];
                message = [NSString stringWithFormat:@"Audio Speech"];
                break;
            case GnAcrStatusTypeNormalMatchMode:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:MODE_KEY];
                message = [NSString stringWithFormat:@"Normal Match Mode"];
                break;
            case GnAcrStatusTypeOnlineLookupComplete:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:ONLINE_KEY];
                message = [NSString stringWithFormat:@"Online Lookup Complete"];
                break;
            case GnAcrStatusTypeQueryBegin:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:ONLINE_KEY];
                message = [NSString stringWithFormat:@"Online Query Begin"];
                break;
            case GnAcrStatusTypeRecordingStarted:
                message = [NSString stringWithFormat:@"Recording Started"];
                break;
            case GnAcrStatusTypeDebug:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:DEBUG_KEY];
                message = [NSString stringWithFormat:@"Debug %@)", status.message];
                break;
            case GnAcrStatusTypeTransition:
                //doShowStatus = ![[NSUserDefaults standardUserDefaults] boolForKey:TRANSITION_KEY];
                message = [NSString stringWithFormat:@"Transition"];
                break;
            default:
                break;
        }
        
        if (doShowStatus && message) {
            //[self updateStatusMessage:[NSString stringWithFormat:@"(%@) ACR Status: %@", [self currentTime], message]];
            NSLog(message);
        }
    }
}

#pragma mark - Gracenote ACR Result Delegate methods

-(void)acrResultReady:(GnResult*)result
{
    @autoreleasepool {
        // ACR query results will be returned in this callback
        // Below is an example of how to access the result metadata.
        
        // These callbacks may occur on threads other than the main thread.
        // Be careful not to block these callbacks for long periods of time.
        
        
        // Get the enumerator to access the ACR Match objects (GnAcrMatch)
        NSEnumerator *matches = result.acrMatches;
        int count = 0;
        
        // for each GnAcrMatch returned in the GnResult
        for (GnAcrMatch *match in matches) {
            count++;
            
            //if (count == 1) {
            //    // remember the first match for use with secondary query
            //    [mLatestAcrMatch release];
            //    mLatestAcrMatch = [match retain];
            //}
            
            // Get the title and subtitle from this GnAcrMatch
            NSString *acrTitle = match.title.display;
            NSString *acrSubtitle = match.subtitle.display;
            
            if (!acrSubtitle) {
                acrSubtitle = @"";
            }
            
            // Retreive the GnTvAiring from the GnAcrMatch
            GnTvAiring *airing = match.tvAiring;
            // Retreive the GnTvChannel from the GnTvAiring
            GnTvChannel *channel = airing.channel;
            
            // Get the Channel callsign for display
            NSString *channelCallsign = channel.callsign;
            
            // Get the position (ms from beginning of work/program) of the GnAcrMatch
            NSString* matchPosition = match.actualPosition;
            NSString* positionFormatted = @"";
            
            if (matchPosition != nil) {
                
                int seconds = [matchPosition intValue] / 1000;
                NSInteger remindMinute = seconds / 60;
                NSInteger remindHours = remindMinute / 60;
                NSInteger remindMinutes = seconds - (remindHours * 3600);
                NSInteger remindMinuteNew = remindMinutes / 60;
                NSInteger remindSecond = seconds - (remindMinuteNew * 60) - (remindHours * 3600);
                positionFormatted = [NSString stringWithFormat:@"%02d:%02d:%02d",remindHours,remindMinuteNew,remindSecond];
            }
            
            if(match.customData){
                NSString *customDataID = match.customData.dataID;
                NSString *resultString = [NSString stringWithFormat:@"ACR: %@ %@ (Match #%d)", customDataID, positionFormatted, count];
                NSLog(resultString);
                //[self updateResultMessage:resultString];
                
            } else {
                NSString *resultString = [NSString stringWithFormat:@"ACR: %@ %@ %@ %@ (Match #%d)", acrTitle, acrSubtitle, channelCallsign, positionFormatted, count];
                NSLog(resultString);
                //[self updateResultMessage:resultString];
            }
            
            // here are more examples of how to get metadata from a result
            if (0) {
                NSLog(@"Match Title :       %@", match.title.display);
                NSLog(@"Match subtitle:     %@", match.subtitle.display);
                NSLog(@"Match actual pos:   %@", match.actualPosition);
                NSLog(@"Match adjusted pos: %@", match.adjustedPosition);
                
                GnVideoWork *work = match.avWork;
                if (work) {
                    NSLog(@"work tui:        %@", work.tui);
                    NSLog(@"work tag:        %@", work.tuiTag);
                    NSLog(@"work title:      %@", work.title.display);
                    NSLog(@"work is partial: %@", work.isPartial?@"YES":@"NO");
                }
                else
                    NSLog(@"No AV Work for this ACR match");
                
                GnTvAiring *airing = match.tvAiring;
                if (airing) {
                    NSLog(@"airing start:   %@", airing.dateStart);
                    NSLog(@"airing end:     %@", airing.dateEnd);
                    
                    
                    GnTvChannel *channel = airing.channel;
                    if (channel) {
                        NSLog(@"channel tui:      %@", channel.tui);
                        NSLog(@"channel tag:      %@", channel.tuiTag);
                        NSLog(@"channel name:     %@", channel.name);
                        NSLog(@"channel callsign: %@", channel.callsign);
                        NSLog(@"channel number:   %@", channel.number);
                    }
                    GnTvProgram *program = airing.tvProgram;
                    if (program) {
                        NSLog(@"program tui:      %@", program.tui);
                        NSLog(@"program tag:      %@", program.tuiTag);
                        NSLog(@"program title:    %@", program.title.display);
                        NSLog(@"program subtitle: %@", program.subtitle.display);
                        GnVideoWork *programWork = program.avWork;
                        if (programWork) {
                            NSLog(@"program work tui:      %@", programWork.tui);
                            NSLog(@"program work tag:      %@", programWork.tuiTag);
                            NSLog(@"program work title:    %@", programWork.title.display);
                        }
                    }
                }
            }
            
            
        }
        if (count == 0) {
            NSLog([NSString stringWithFormat:@"ACR: No match (%@)", [self currentTime]]);
            //[self updateResultMessage:[NSString stringWithFormat:@"ACR: No match (%@)", [self currentTime]]];
        }
        
        
        
    }

}

#pragma mark - Gracenote Helper methods

- (void)initManagerWithError:(NSError **)error
{
    // Create/init a manager with customers's license. Only create one manager per app instance.
    if (!self.gracenoteSdkManager) {
        
        self.gracenoteSdkManager = [[GnSdkManager alloc] initWithLicense:LICENSE_STRING error:error];
        
        // set up local cacheing
        if(self.gracenoteSdkManager){
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                 NSUserDomainMask,
                                                                 YES);
            
            // It is advised to explicitly set the storage folders for the SDK.
            // These paths are used intenally to the SDK but the application may decide the
            // best location for certain caches.
            NSString *cacheFolderPath = [paths objectAtIndex:0];
            [GnStorageSqlite setStorageFolder:cacheFolderPath error:error];
            // [GnStorageSqlite setStorageFileSize:10240 error:error];     // 5 MB
            [GnStorageSqlite setStorageMemorySize:512 error:error];    // 512 KB
            
            // It is advised to explicitly set the GnFPCache storage folder on each launch.
            [GnFPCache setStorageFolder:cacheFolderPath error:error];
            
            // now we can ingest any bundles we have available
            // [self loadFPBundle];
        }
    }
}

-(void)initAcrUserWithError:(NSError **)error
{
    // It is best practice to cache users after the first launch of the app.
    // This sample code shows how to serialize and save the user for subsequent launches.
    
    if (!self.gracenoteUser) {
        
        NSString *savedUser = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_USER_KEY_ACR];
        
        if (savedUser)
        {
            self.gracenoteUser = [[GnUser alloc] initWithSerializedUser:savedUser error:error];
        }
        else
        {
            self.gracenoteUser = [[GnUser alloc] initWithClientId:CLIENT_ID
                                            clientIdTag:CLIENT_ID_TAG
                                             appVersion:@"1.0"
                                       registrationType:GnUserRegistrationType_NewUser error:error];
            
            if (self.gracenoteUser) {
                // this should be saved somewhere secure like the keychain,
                // but this is outside the scope of the sample code.
                [[NSUserDefaults standardUserDefaults] setObject:self.gracenoteUser.serializedUser
                                                          forKey:SAVED_USER_KEY_ACR];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}

- (void)stopACR
{
    NSError *error;
    error = [self.gracenoteAudioSource stop];
    
    if (error) {
        
        NSLog(@"Failed to stop Gracenote Audio Source");
        
    } else {
        
        self.gracenoteAudioSource = nil;
        
        // Deallocation of GnAcr objects may block until all status and result delegate callbacks are complete.
        // Be careful not to block these callbacks for long periods of time.
        // Also, do not release GnAcr objects in the delegate callbacks
        self.gracenoteAcr = nil;
    
        // schedule this UI update after any pending Status/Result UI updates
        //[self performSelectorOnMainThread:@selector(updateStatusMessage:) withObject:msg waitUntilDone:NO];
    }
}

#pragma mark - Helpers

-(NSString*) currentTime{
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    NSDate *now = [[NSDate alloc] init];
    NSString *theTime = [timeFormat stringFromDate:now];
    return theTime;
}

@end

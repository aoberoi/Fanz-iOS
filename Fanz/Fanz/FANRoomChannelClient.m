//
//  FANRoomChannelClient.m
//  Fanz
//
//  Created by Ankur Oberoi on 4/28/13.
//  Copyright (c) 2013 Ankur Oberoi. All rights reserved.
//

#import "FANRoomChannelClient.h"
#import <FacebookSDK/Facebook.h>
#import <FacebookSDK/FBGraphUser.h>
#import <NSString+RMURLEncoding/NSString+RMURLEncoding.h>
#import "FANRoom.h"
#import <JSONKit/JSONKit.h>

NSString *const kFANRoomChannelClientDidRecieveResponseNotification = @"RoomChannelClientDidRecieveResponse";
NSString *const kFANRoomChannelClientDidCreateRoomNotification = @"RoomChannelClientDidCreateRoom";

@interface FANRoomChannelClient ()

- (void)makeRequest;
// TODO: make this a class method, or better yet put it in a separate category
- (NSString *)encodeQueryParams:(NSDictionary *)parameterDictionary;
- (void)parseJson:(NSDictionary *)json;

@property (assign) BOOL didRecieveRoomData;

@end

@implementation FANRoomChannelClient

- initWithTui:(NSString *)tui tuiTag:(NSString *)tuiTag matchTime:(NSString *)matchTime
{
    self = [super init];
    if (self) {
        self.tui = tui;
        self.tuiTag = tuiTag;
        self.matchTime = matchTime;
        self.didRecieveRoomData = NO;
        if (!FBSession.activeSession.isOpen) {
            [FBSession openActiveSessionWithAllowLoginUI:YES];
        }
        NSLog(@"about to start facebook 'me' request");
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            // assign self.username;
            if (error) {
                NSLog(@"error getting 'me' from facebook");
                return;
            }
            
            NSLog(@"got facebook graph object for 'me'");
            
            FBGraphObject<FBGraphUser> *me = (FBGraphObject<FBGraphUser> *)result;
            
            self.username = me.username;
            
            [self makeRequest];
        }];
    }
    return self;
}

- (void)makeRequest
{
    NSString *requestURL = [NSString stringWithFormat:@"http://http://ec2-54-244-209-3.us-west-2.compute.amazonaws.com:5000/join/%@-%@?%@", self.tui, self.tuiTag, [self encodeQueryParams:@{@"username": self.username, @"match_time": self.matchTime}]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestURL]];
    request.shouldAttemptPersistentConnection = YES;
    request.delegate = self;
    [request startAsynchronous];
    NSLog(@"started request with URL: %@", requestURL);
}

- (NSString *)encodeQueryParams:(NSDictionary *)parameterDictionary
{
    NSMutableString *result = [NSMutableString stringWithString:@""];
    [parameterDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *keyString = (NSString *)key;
        NSString *valueString = (NSString *)obj;
        [result appendString:[keyString rm_URLEncodedString]];
        [result appendString:@"="];
        [result appendString:[valueString rm_URLEncodedString]];
        [result appendString:@"&"];
    }];
    [result deleteCharactersInRange:NSMakeRange(result.length - 1, 1)];
    return [result copy];
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFANRoomChannelClientDidRecieveResponseNotification
                                                        object:self
                                                      userInfo:@{ @"responseHeaders" : responseHeaders }];
    
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data;
{
    NSLog(@"Did recieve bytes:");
    // trying to encode the bytes as a string
    
    NSDictionary *json = (NSDictionary *)[[JSONDecoder decoder] objectWithData:data];
    
    if (self.didRecieveRoomData) {
        [self parseJson:json];
        return;
    }
    
    FANRoom *room = [[FANRoom alloc] initWithJson:json];
    
    if (room) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFANRoomChannelClientDidCreateRoomNotification
                                                            object:self
                                                          userInfo:@{ @"room" : room }];
        self.didRecieveRoomData = YES;
    } else {
        // raise an exception
        NSException *e = [[NSException alloc] initWithName:@"room creation failed" reason:@"" userInfo:@{}];
        [e raise];
    }
    
}

- (void)parseJson:(NSDictionary *)json
{
    NSLog(@"recieved json: %@", [json description]);
}

@end

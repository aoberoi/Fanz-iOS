//
//  FANRoomChannelClient.h
//  Fanz
//
//  Created by Ankur Oberoi on 4/28/13.
//  Copyright (c) 2013 Ankur Oberoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>

extern NSString *const kFANRoomChannelClientDidRecieveResponseNotification;
extern NSString *const kFANRoomChannelClientDidCreateRoomNotification;

@interface FANRoomChannelClient : NSObject <ASIHTTPRequestDelegate>

- initWithTui:(NSString *)tui tuiTag:(NSString *)tuiTag matchTime:(NSString *)matchTime;

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders;
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data;

@property (strong, nonatomic) ASIHTTPRequest *request;

@property (strong, nonatomic) NSString *tui;
@property (strong, nonatomic) NSString *tuiTag;
@property (strong, nonatomic) NSString *matchTime;
@property (strong, nonatomic) NSString *username;

@end

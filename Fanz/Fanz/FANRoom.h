//
//  FANRoom.h
//  Fanz
//
//  Created by Ankur Oberoi on 4/28/13.
//  Copyright (c) 2013 Ankur Oberoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FANRoom : NSObject

- (id)initWithJson:(NSDictionary *)json;

@property NSDictionary *homeTeam;
@property NSDictionary *awayTeam;
@property NSArray *members;
@property NSString *sessionId;
@property NSString *title;

@end

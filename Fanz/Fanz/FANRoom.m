//
//  FANRoom.m
//  Fanz
//
//  Created by Ankur Oberoi on 4/28/13.
//  Copyright (c) 2013 Ankur Oberoi. All rights reserved.
//

#import "FANRoom.h"

@implementation FANRoom

- (id)init
{
    return nil;
}

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if (self) {
        // TODO: populate room properties from json
        NSLog(@"create room with json: %@", [json description]);
        
        self.homeTeam = @{
            @"location": json[@"roomdata"][@"teams"][@"home"][@"location"],
            @"name": json[@"roomdata"][@"teams"][@"home"][@"name"],
            @"score": json[@"roomdata"][@"teams"][@"home"][@"score"]
        };
        
        self.awayTeam = @{
            @"location": json[@"roomdata"][@"teams"][@"away"][@"location"],
            @"name": json[@"roomdata"][@"teams"][@"away"][@"name"],
            @"score": json[@"roomdata"][@"teams"][@"away"][@"score"]
        };
        
        self.members = json[@"inroom"];
        
        self.sessionId = json[@"session"];
        
        self.title = json[@"title"];
        
    }
    return self;
}

@end

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
        
    }
    return self;
}

@end

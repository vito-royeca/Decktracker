//
//  DTSetType.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTSetType.h"

@implementation DTSetType

+ (NSString *)primaryKey
{
    return @"setTypeId";
}

+ (NSArray *)indexedProperties
{
    return @[@"name"];
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{ @"name": @"",
              @"setTypeId" : [[NSUUID UUID] UUIDString] };
}

@end

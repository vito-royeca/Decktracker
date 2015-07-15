//
//  DTCardColor.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTCardColor.h"

@implementation DTCardColor

+ (NSString *)primaryKey
{
    return @"colorId";
}

+ (NSArray *)indexedProperties
{
    return @[@"name"];
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{ @"colorId" : [[NSUUID UUID] UUIDString],
              @"name": @"" };
}

@end

//
//  DTFormat.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTFormat.h"

@implementation DTFormat

+ (NSString *)primaryKey
{
    return @"formatId";
}

+ (NSArray *)indexedProperties
{
    return @[@"name"];
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{ @"formatId" : [[NSUUID UUID] UUIDString],
              @"name": @"" };
}

@end

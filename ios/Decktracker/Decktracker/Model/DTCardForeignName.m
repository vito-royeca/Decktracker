//
//  DTCardForeignName.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTCardForeignName.h"

@implementation DTCardForeignName

+ (NSString *)primaryKey
{
    return @"foreignNameId";
}

+ (NSArray *)indexedProperties
{
    return @[@"name"];
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{ @"foreignNameId" : [[NSUUID UUID] UUIDString],
              @"name": @"" };
}

@end

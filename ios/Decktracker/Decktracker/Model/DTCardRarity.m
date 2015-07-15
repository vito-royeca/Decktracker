//
//  DTCardRarity.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTCardRarity.h"

@implementation DTCardRarity

+ (NSString *)primaryKey
{
    return @"rarityId";
}

+ (NSArray *)indexedProperties
{
    return @[@"name", @"symbol"];
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{ @"name": @"",
              @"rarityId" : [[NSUUID UUID] UUIDString],
              @"symbol" : @""};
}

@end

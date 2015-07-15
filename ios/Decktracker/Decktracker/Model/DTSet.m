//
//  DTSet.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTSet.h"

@implementation DTSet

+ (NSString *)primaryKey
{
    return @"setId";
}

+ (NSArray *)indexedProperties
{
    return @[@"name", @"code", @"tcgPlayerName", @"magicCardsInfoCode"];
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{ @"border" : @"",
              @"code" : @"",
              @"gathererCode" : @"",
              @"magicCardsInfoCode" : @"",
              @"name": @"",
              @"numberOfCards" : @0,
              @"oldCode" : @"",
              @"onlineOnly" : @NO,
              @"releaseDate" : [NSDate date],
              @"sectionNameInitial" : @"",
              @"sectionYear" : @"",
              @"setId" : [[NSUUID UUID] UUIDString],
              @"tcgPlayerName" : @"" };
}

@end

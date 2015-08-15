//
//  DTCard.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTCard.h"

@implementation DTCard

+ (NSString *)primaryKey
{
    return @"cardId";
}

+ (NSArray *)indexedProperties
{
    return @[@"name", @"number", @"multiverseID"];
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{ @"border" : @"",
              @"cardId" : [[NSUUID UUID] UUIDString],
              @"cmc" : @-1.0,
              @"flavor" : @"",
              @"handModifier" : @-1,
              @"imageName" : @"",
              @"layout" : @"",
              @"lifeModifier" : @-1,
              @"loyalty" : @-1,
              @"manaCost" : @"",
              @"modern" : @NO,
              @"multiverseID" : @-1,
              @"name" : @"",
              @"number" : @"",
              @"originalText" : @"",
              @"originalType" : @"",
              @"parseFetchDate" : [[NSDate alloc] initWithTimeIntervalSince1970:0],
              @"power" : @"",
              @"rating" : @0.0,
              @"releaseDate" : @"",
              @"reserved" : @NO,
              @"sectionColor" : @"",
              @"sectionNameInitial" : @"",
              @"sectionType" : @"",
              @"source" : @"",
              @"starter" : @NO,
              @"tcgPlayerFetchDate" : [[NSDate alloc] initWithTimeIntervalSince1970:0],
              @"tcgPlayerFoilPrice" : @0.0,
              @"tcgPlayerHighPrice" : @0.0,
              @"tcgPlayerLink" : @"",
              @"tcgPlayerLowPrice" : @0.0,
              @"tcgPlayerMidPrice" : @0.0,
              @"text" : @"",
              @"timeshifted" : @NO,
              @"toughness" : @"",
              @"type" : @"",
              @"watermark" : @"" };
}

@end

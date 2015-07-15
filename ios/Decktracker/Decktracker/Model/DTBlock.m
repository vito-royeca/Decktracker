//
//  DTBlock.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTBlock.h"
#import "DTSet.h"


@implementation DTBlock

+ (NSString *)primaryKey
{
    return @"blockId";
}

+ (NSArray *)indexedProperties
{
    return @[@"name"];
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{ @"blockId" : [[NSUUID UUID] UUIDString],
              @"name": @"" };
}

@end

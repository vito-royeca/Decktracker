//
//  DTCardRating.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTCardRating.h"

@implementation DTCardRating

+ (NSString *)primaryKey
{
    return @"ratingId";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{ @"rating": @0,
              @"ratingId" : [[NSUUID UUID] UUIDString]};
}

@end

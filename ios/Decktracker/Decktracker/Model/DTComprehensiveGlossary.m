//
//  DTComprehensiveGlossary.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTComprehensiveGlossary.h"

@implementation DTComprehensiveGlossary

+ (NSString *)primaryKey
{
    return @"glossaryId";
}

+ (NSArray *)indexedProperties
{
    return @[@"term"];
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"definition" : @"",
              @"glossaryId" : [[NSUUID UUID] UUIDString],
              @"term": @"" };
}

@end

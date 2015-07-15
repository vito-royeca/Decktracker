//
//  DTComprehensiveRule.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTComprehensiveRule.h"

@implementation DTComprehensiveRule

+ (NSString *)primaryKey
{
    return @"ruleId";
}

+ (NSArray *)indexedProperties
{
    return @[@"number"];
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{ @"number": @"",
              @"ruleId" : [[NSUUID UUID] UUIDString],
              @"rule": @"" };
}

@end

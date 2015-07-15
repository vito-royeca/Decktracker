//
//  DTLanguage.m
//  Decktracker
//
//  Created by Jovit Royeca on 6/1/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

#import "DTLanguage.h"

@implementation DTLanguage

+ (NSString *)primaryKey
{
    return @"languageId";
}

+ (NSArray *)indexedProperties
{
    return @[@"name"];
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{ @"languageId" : [[NSUUID UUID] UUIDString],
              @"name": @"" };
}

@end

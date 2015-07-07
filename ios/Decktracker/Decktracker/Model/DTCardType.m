//
//  DTCardType.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTCardType.h"

@implementation DTCardType

+ (NSString *)primaryKey {
    return @"cardTypeId";
}

+ (NSArray *)indexedProperties {
    return @[@"name"];
}

@end

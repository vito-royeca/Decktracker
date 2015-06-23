//
//  DTSet.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTSet.h"

@implementation DTSet

+ (NSString *)primaryKey {
    return @"setId";
}

+ (NSArray *)indexedProperties {
    return @[@"code", @"name"];
}

@end

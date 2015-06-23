//
//  DTCard.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTCard.h"

@implementation DTCard

+ (NSString *)primaryKey {
    return @"cardId";
}

+ (NSArray *)indexedProperties {
    return @[@"name", @"multiverseID"];
}

@end

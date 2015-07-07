//
//  DTArtist.m
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DTArtist.h"
#import "DTCard.h"


@implementation DTArtist

+ (NSString *)primaryKey {
    return @"artistId";
}

+ (NSArray *)indexedProperties {
    return @[@"name"];
}

@end

//
//  Format.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/19/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "Format.h"
#import "CardLegality.h"


@implementation Format

@dynamic name;
@dynamic legalities;

-(NSString*) description
{
    return self.name;
}

@end

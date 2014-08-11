//
//  CardLegality.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/11/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card, Format;

@interface CardLegality : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Card *card;
@property (nonatomic, retain) Format *format;

@end

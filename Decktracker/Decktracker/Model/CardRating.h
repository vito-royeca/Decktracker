//
//  CardRating.h
//  Decktracker
//
//  Created by Jovit Royeca on 11/17/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card;

@interface CardRating : NSManagedObject

@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) Card *card;

@end

//
//  CardForeignName.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/14/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card;

@interface CardForeignName : NSManagedObject

@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Card *card;

@end

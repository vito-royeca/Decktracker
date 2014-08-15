//
//  Set.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/14/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Block, Card, SetType;

@interface Set : NSManagedObject

@property (nonatomic, retain) NSString * border;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * gathererCode;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfCards;
@property (nonatomic, retain) NSString * oldCode;
@property (nonatomic, retain) NSNumber * onlineOnly;
@property (nonatomic, retain) NSDate * releaseDate;
@property (nonatomic, retain) NSString * tcgPlayerName;
@property (nonatomic, retain) Block *block;
@property (nonatomic, retain) NSSet *cards;
@property (nonatomic, retain) NSSet *printings;
@property (nonatomic, retain) SetType *type;
@end

@interface Set (CoreDataGeneratedAccessors)

- (void)addCardsObject:(Card *)value;
- (void)removeCardsObject:(Card *)value;
- (void)addCards:(NSSet *)values;
- (void)removeCards:(NSSet *)values;

- (void)addPrintingsObject:(Card *)value;
- (void)removePrintingsObject:(Card *)value;
- (void)addPrintings:(NSSet *)values;
- (void)removePrintings:(NSSet *)values;

@end

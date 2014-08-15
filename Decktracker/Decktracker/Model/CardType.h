//
//  CardType.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/14/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card;

@interface CardType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *cardSubTypes;
@property (nonatomic, retain) NSSet *cardSuperTypes;
@property (nonatomic, retain) NSSet *cardTypes;
@end

@interface CardType (CoreDataGeneratedAccessors)

- (void)addCardSubTypesObject:(Card *)value;
- (void)removeCardSubTypesObject:(Card *)value;
- (void)addCardSubTypes:(NSSet *)values;
- (void)removeCardSubTypes:(NSSet *)values;

- (void)addCardSuperTypesObject:(Card *)value;
- (void)removeCardSuperTypesObject:(Card *)value;
- (void)addCardSuperTypes:(NSSet *)values;
- (void)removeCardSuperTypes:(NSSet *)values;

- (void)addCardTypesObject:(Card *)value;
- (void)removeCardTypesObject:(Card *)value;
- (void)addCardTypes:(NSSet *)values;
- (void)removeCardTypes:(NSSet *)values;

@end

//
//  DTCardType.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTCard;

@interface DTCardType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *cardSubTypes;
@property (nonatomic, retain) NSSet *cardSuperTypes;
@property (nonatomic, retain) NSSet *cardTypes;
@end

@interface DTCardType (CoreDataGeneratedAccessors)

- (void)addCardSubTypesObject:(DTCard *)value;
- (void)removeCardSubTypesObject:(DTCard *)value;
- (void)addCardSubTypes:(NSSet *)values;
- (void)removeCardSubTypes:(NSSet *)values;

- (void)addCardSuperTypesObject:(DTCard *)value;
- (void)removeCardSuperTypesObject:(DTCard *)value;
- (void)addCardSuperTypes:(NSSet *)values;
- (void)removeCardSuperTypes:(NSSet *)values;

- (void)addCardTypesObject:(DTCard *)value;
- (void)removeCardTypesObject:(DTCard *)value;
- (void)addCardTypes:(NSSet *)values;
- (void)removeCardTypes:(NSSet *)values;

@end

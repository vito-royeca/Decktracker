//
//  Card.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/19/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist, Card, CardColor, CardForeignName, CardLegality, CardRarity, CardRuling, CardType, Set;

@interface Card : NSManagedObject

@property (nonatomic, retain) NSString * border;
@property (nonatomic, retain) NSNumber * cmc;
@property (nonatomic, retain) NSString * flavor;
@property (nonatomic, retain) NSNumber * handModifier;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSString * layout;
@property (nonatomic, retain) NSNumber * lifeModifier;
@property (nonatomic, retain) NSNumber * loyalty;
@property (nonatomic, retain) NSString * manaCost;
@property (nonatomic, retain) NSNumber * multiverseID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * originalText;
@property (nonatomic, retain) NSString * power;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * timeshifted;
@property (nonatomic, retain) NSString * toughness;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * watermark;
@property (nonatomic, retain) Artist *artist;
@property (nonatomic, retain) NSSet *colors;
@property (nonatomic, retain) NSSet *foreignNames;
@property (nonatomic, retain) NSSet *legalities;
@property (nonatomic, retain) NSSet *names;
@property (nonatomic, retain) NSSet *printings;
@property (nonatomic, retain) CardRarity *rarity;
@property (nonatomic, retain) NSSet *rulings;
@property (nonatomic, retain) Set *set;
@property (nonatomic, retain) NSSet *subTypes;
@property (nonatomic, retain) NSSet *superTypes;
@property (nonatomic, retain) NSSet *types;
@property (nonatomic, retain) NSSet *variations;
@end

@interface Card (CoreDataGeneratedAccessors)

- (void)addColorsObject:(CardColor *)value;
- (void)removeColorsObject:(CardColor *)value;
- (void)addColors:(NSSet *)values;
- (void)removeColors:(NSSet *)values;

- (void)addForeignNamesObject:(CardForeignName *)value;
- (void)removeForeignNamesObject:(CardForeignName *)value;
- (void)addForeignNames:(NSSet *)values;
- (void)removeForeignNames:(NSSet *)values;

- (void)addLegalitiesObject:(CardLegality *)value;
- (void)removeLegalitiesObject:(CardLegality *)value;
- (void)addLegalities:(NSSet *)values;
- (void)removeLegalities:(NSSet *)values;

- (void)addNamesObject:(Card *)value;
- (void)removeNamesObject:(Card *)value;
- (void)addNames:(NSSet *)values;
- (void)removeNames:(NSSet *)values;

- (void)addPrintingsObject:(Set *)value;
- (void)removePrintingsObject:(Set *)value;
- (void)addPrintings:(NSSet *)values;
- (void)removePrintings:(NSSet *)values;

- (void)addRulingsObject:(CardRuling *)value;
- (void)removeRulingsObject:(CardRuling *)value;
- (void)addRulings:(NSSet *)values;
- (void)removeRulings:(NSSet *)values;

- (void)addSubTypesObject:(CardType *)value;
- (void)removeSubTypesObject:(CardType *)value;
- (void)addSubTypes:(NSSet *)values;
- (void)removeSubTypes:(NSSet *)values;

- (void)addSuperTypesObject:(CardType *)value;
- (void)removeSuperTypesObject:(CardType *)value;
- (void)addSuperTypes:(NSSet *)values;
- (void)removeSuperTypes:(NSSet *)values;

- (void)addTypesObject:(CardType *)value;
- (void)removeTypesObject:(CardType *)value;
- (void)addTypes:(NSSet *)values;
- (void)removeTypes:(NSSet *)values;

- (void)addVariationsObject:(Card *)value;
- (void)removeVariationsObject:(Card *)value;
- (void)addVariations:(NSSet *)values;
- (void)removeVariations:(NSSet *)values;

@end

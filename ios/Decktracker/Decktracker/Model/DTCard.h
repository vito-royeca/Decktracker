//
//  DTCard.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTArtist, DTCard, DTCardColor, DTCardForeignName, DTCardLegality, DTCardRarity, DTCardRating, DTCardRuling, DTCardType, DTSet;

@interface DTCard : NSManagedObject

@property (nonatomic, retain) NSString * border;
@property (nonatomic, retain) NSNumber * cardID;
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
@property (nonatomic, retain) NSString * originalType;
@property (nonatomic, retain) NSString * power;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * releaseDate;
@property (nonatomic, retain) NSNumber * reserved;
@property (nonatomic, retain) NSString * sectionColor;
@property (nonatomic, retain) NSString * sectionNameInitial;
@property (nonatomic, retain) NSString * sectionType;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSDate * tcgPlayerFetchDate;
@property (nonatomic, retain) NSNumber * tcgPlayerFoilPrice;
@property (nonatomic, retain) NSNumber * tcgPlayerHighPrice;
@property (nonatomic, retain) NSString * tcgPlayerLink;
@property (nonatomic, retain) NSNumber * tcgPlayerLowPrice;
@property (nonatomic, retain) NSNumber * tcgPlayerMidPrice;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * timeshifted;
@property (nonatomic, retain) NSString * toughness;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * watermark;
@property (nonatomic, retain) DTArtist *artist;
@property (nonatomic, retain) NSSet *colors;
@property (nonatomic, retain) NSSet *foreignNames;
@property (nonatomic, retain) NSSet *legalities;
@property (nonatomic, retain) NSSet *names;
@property (nonatomic, retain) NSSet *printings;
@property (nonatomic, retain) DTCardRarity *rarity;
@property (nonatomic, retain) NSSet *ratings;
@property (nonatomic, retain) NSSet *rulings;
@property (nonatomic, retain) DTSet *set;
@property (nonatomic, retain) NSSet *subTypes;
@property (nonatomic, retain) NSSet *superTypes;
@property (nonatomic, retain) NSSet *types;
@property (nonatomic, retain) NSSet *variations;
@end

@interface DTCard (CoreDataGeneratedAccessors)

- (void)addColorsObject:(DTCardColor *)value;
- (void)removeColorsObject:(DTCardColor *)value;
- (void)addColors:(NSSet *)values;
- (void)removeColors:(NSSet *)values;

- (void)addForeignNamesObject:(DTCardForeignName *)value;
- (void)removeForeignNamesObject:(DTCardForeignName *)value;
- (void)addForeignNames:(NSSet *)values;
- (void)removeForeignNames:(NSSet *)values;

- (void)addLegalitiesObject:(DTCardLegality *)value;
- (void)removeLegalitiesObject:(DTCardLegality *)value;
- (void)addLegalities:(NSSet *)values;
- (void)removeLegalities:(NSSet *)values;

- (void)addNamesObject:(DTCard *)value;
- (void)removeNamesObject:(DTCard *)value;
- (void)addNames:(NSSet *)values;
- (void)removeNames:(NSSet *)values;

- (void)addPrintingsObject:(DTSet *)value;
- (void)removePrintingsObject:(DTSet *)value;
- (void)addPrintings:(NSSet *)values;
- (void)removePrintings:(NSSet *)values;

- (void)addRatingsObject:(DTCardRating *)value;
- (void)removeRatingsObject:(DTCardRating *)value;
- (void)addRatings:(NSSet *)values;
- (void)removeRatings:(NSSet *)values;

- (void)addRulingsObject:(DTCardRuling *)value;
- (void)removeRulingsObject:(DTCardRuling *)value;
- (void)addRulings:(NSSet *)values;
- (void)removeRulings:(NSSet *)values;

- (void)addSubTypesObject:(DTCardType *)value;
- (void)removeSubTypesObject:(DTCardType *)value;
- (void)addSubTypes:(NSSet *)values;
- (void)removeSubTypes:(NSSet *)values;

- (void)addSuperTypesObject:(DTCardType *)value;
- (void)removeSuperTypesObject:(DTCardType *)value;
- (void)addSuperTypes:(NSSet *)values;
- (void)removeSuperTypes:(NSSet *)values;

- (void)addTypesObject:(DTCardType *)value;
- (void)removeTypesObject:(DTCardType *)value;
- (void)addTypes:(NSSet *)values;
- (void)removeTypes:(NSSet *)values;

- (void)addVariationsObject:(DTCard *)value;
- (void)removeVariationsObject:(DTCard *)value;
- (void)addVariations:(NSSet *)values;
- (void)removeVariations:(NSSet *)values;

@end

//
//  DTCard.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Realm/Realm.h>
#import "RLMArrays.h"

@class DTArtist, DTCard, DTCardColor, DTCardForeignName, DTCardLegality, DTCardRarity, DTCardRating, DTCardRuling, DTCardType, DTSet;

@interface DTCard : RLMObject

@property NSString * border;
@property float cmc;
@property NSString * flavor;
@property int handModifier;
@property NSString * imageName;
@property NSString * layout;
@property int lifeModifier;
@property int loyalty;
@property NSString * manaCost;
@property int multiverseID;
@property NSString * name;
@property NSString * number;
@property NSString * originalText;
@property NSString * originalType;
@property NSString * power;
@property double rating;
@property NSString * releaseDate;
@property BOOL reserved;
@property NSString * sectionColor;
@property NSString * sectionNameInitial;
@property NSString * sectionType;
@property NSString * source;
@property BOOL starter;
@property NSDate * tcgPlayerFetchDate;
@property double tcgPlayerFoilPrice;
@property double tcgPlayerHighPrice;
@property NSString * tcgPlayerLink;
@property double tcgPlayerLowPrice;
@property double tcgPlayerMidPrice;
@property NSString * text;
@property BOOL timeshifted;
@property NSString * toughness;
@property NSString * type;
@property NSString * watermark;
@property DTArtist *artist;
@property RLMArray<DTCardColor> *colors;
@property RLMArray<DTCardForeignName> *foreignNames;
@property RLMArray<DTCardLegality> *legalities;
@property RLMArray<DTCard> *names;
@property RLMArray<DTSet> *printings;
@property DTCardRarity *rarity;
@property RLMArray<DTCardRating> *ratings;
@property RLMArray<DTCardRuling> *rulings;
@property DTSet *set;
@property RLMArray<DTCardType> *subTypes;
@property RLMArray<DTCardType> *superTypes;
@property RLMArray<DTCardType> *types;
@property RLMArray<DTCard> *variations;

@end



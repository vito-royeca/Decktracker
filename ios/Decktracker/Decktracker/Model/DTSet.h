//
//  DTSet.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Realm/Realm.h>
#import "RLMArrays.h"

@class DTBlock, DTCard, DTLanguage, DTSetType;

@interface DTSet : RLMObject

@property NSString * border;
@property NSString * code;
@property NSString * gathererCode;
@property NSString * magicCardsInfoCode;
@property BOOL imagesDownloaded;
@property NSString * name;
@property int numberOfCards;
@property NSString * oldCode;
@property BOOL onlineOnly;
@property NSDate * releaseDate;
@property NSString * sectionNameInitial;
@property NSString * sectionYear;
@property NSString * tcgPlayerName;
@property DTBlock *block;
@property RLMArray<DTLanguage> *languages;
@property DTSetType *type;

@end

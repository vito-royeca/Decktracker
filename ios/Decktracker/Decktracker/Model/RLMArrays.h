//
//  RLMArrays.h
//  DataSource
//
//  Created by Jovit Royeca on 5/11/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

#ifndef DataSource_RLMArrays_h
#define DataSource_RLMArrays_h

#import <Realm/Realm.h>

@class
DTArtist,
DTBlock,
DTCard,
DTCardColor,
DTCardForeignName,
DTCardLegality,
DTCardRarity,
DTCardRating,
DTCardRuling,
DTCardType,
DTComprehensiveGlossary,
DTComprehensiveRule,
DTFormat,
DTLanguage,
DTSet,
DTSetType;

RLM_ARRAY_TYPE(DTArtist)
RLM_ARRAY_TYPE(DTBlock)
RLM_ARRAY_TYPE(DTCard)
RLM_ARRAY_TYPE(DTCardColor)
RLM_ARRAY_TYPE(DTCardForeignName)
RLM_ARRAY_TYPE(DTCardLegality)
RLM_ARRAY_TYPE(DTCardRarity)
RLM_ARRAY_TYPE(DTCardRating)
RLM_ARRAY_TYPE(DTCardRuling)
RLM_ARRAY_TYPE(DTCardType)
RLM_ARRAY_TYPE(DTComprehensiveGlossary)
RLM_ARRAY_TYPE(DTComprehensiveRule)
RLM_ARRAY_TYPE(DTFormat)
RLM_ARRAY_TYPE(DTLanguage)
RLM_ARRAY_TYPE(DTSet)
RLM_ARRAY_TYPE(DTSetType)

#endif

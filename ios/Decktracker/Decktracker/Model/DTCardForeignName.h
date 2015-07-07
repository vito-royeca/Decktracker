//
//  DTCardForeignName.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Realm/Realm.h>
//#import "RLMArrays.h"

@class DTCard, DTLanguage;

@interface DTCardForeignName : RLMObject

@property NSString * foreignNameId;
@property NSString * name;
@property DTCard *card;
@property DTLanguage *language;

@end

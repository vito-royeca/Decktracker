//
//  DTCardRarity.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Realm/Realm.h>
//#import "RLMArrays.h"

//@class DTCard;

@interface DTCardRarity : RLMObject

@property NSString * name;
@property NSString * rarityId;
@property NSString * symbol;
//@property RLMArray<DTCard> *cards;

@end



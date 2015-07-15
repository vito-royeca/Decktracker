//
//  DTFormat.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Realm/Realm.h>
//#import "RLMArrays.h"

//@class DTCardLegality;

@interface DTFormat : RLMObject

@property NSString * formatId;
@property NSString * name;
//@property RLMArray<DTCardLegality> *legalities;

@end

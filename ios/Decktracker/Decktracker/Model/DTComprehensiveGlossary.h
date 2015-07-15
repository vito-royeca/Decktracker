//
//  DTComprehensiveGlossary.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Realm/Realm.h>
#import "RLMArrays.h"

@class DTComprehensiveRule;

@interface DTComprehensiveGlossary : RLMObject

@property NSString * definition;
@property NSString * glossaryId;
@property NSString * term;
@property RLMArray<DTComprehensiveRule> *rules;

@end

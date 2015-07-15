//
//  DTComprehensiveRule.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Realm/Realm.h>
#import "RLMArrays.h"

@class DTComprehensiveGlossary;

@interface DTComprehensiveRule : RLMObject

@property NSString * ruleId;
@property NSString * number;
@property NSString * rule;
@property RLMArray<DTComprehensiveRule> *children;
@property DTComprehensiveGlossary *glossary;
@property DTComprehensiveRule *parent;

@end

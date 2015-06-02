//
//  DTCardForeignName.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Realm/Realm.h>
//#import "RLMArrays.h"

@class DTLanguage;

@interface DTCardForeignName : RLMObject

@property NSString * name;
@property DTLanguage *language;

@end

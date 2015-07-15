//
//  DTBlock.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Realm/Realm.h>
//#import "RLMArrays.h"

//@class DTSet;

@interface DTBlock : RLMObject

@property NSString *blockId;
@property NSString * name;
//@property RLMArray<DTSet> *sets;

@end


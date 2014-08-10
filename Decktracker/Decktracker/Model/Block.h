//
//  Block.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/8/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Set;

@interface Block : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *sets;
@end

@interface Block (CoreDataGeneratedAccessors)

- (void)addSetsObject:(Set *)value;
- (void)removeSetsObject:(Set *)value;
- (void)addSets:(NSSet *)values;
- (void)removeSets:(NSSet *)values;

@end

//
//  DTBlock.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTSet;

@interface DTBlock : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *sets;
@end

@interface DTBlock (CoreDataGeneratedAccessors)

- (void)addSetsObject:(DTSet *)value;
- (void)removeSetsObject:(DTSet *)value;
- (void)addSets:(NSSet *)values;
- (void)removeSets:(NSSet *)values;

@end

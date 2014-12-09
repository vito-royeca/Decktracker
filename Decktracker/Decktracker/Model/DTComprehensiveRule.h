//
//  DTComprehensiveRule.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTComprehensiveGlossary, DTComprehensiveRule;

@interface DTComprehensiveRule : NSManagedObject

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * rule;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) DTComprehensiveGlossary *glossary;
@property (nonatomic, retain) DTComprehensiveRule *parent;
@end

@interface DTComprehensiveRule (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(DTComprehensiveRule *)value;
- (void)removeChildrenObject:(DTComprehensiveRule *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end

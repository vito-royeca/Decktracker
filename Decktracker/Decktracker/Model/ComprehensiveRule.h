//
//  ComprehensiveRule.h
//  Decktracker
//
//  Created by Jovit Royeca on 11/5/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ComprehensiveGlossary, ComprehensiveRule;

@interface ComprehensiveRule : NSManagedObject

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * rule;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) ComprehensiveGlossary *glossary;
@property (nonatomic, retain) ComprehensiveRule *parent;
@end

@interface ComprehensiveRule (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(ComprehensiveRule *)value;
- (void)removeChildrenObject:(ComprehensiveRule *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end

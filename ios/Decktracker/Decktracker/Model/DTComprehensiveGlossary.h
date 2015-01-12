//
//  DTComprehensiveGlossary.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTComprehensiveRule;

@interface DTComprehensiveGlossary : NSManagedObject

@property (nonatomic, retain) NSString * definition;
@property (nonatomic, retain) NSString * term;
@property (nonatomic, retain) NSSet *rules;
@end

@interface DTComprehensiveGlossary (CoreDataGeneratedAccessors)

- (void)addRulesObject:(DTComprehensiveRule *)value;
- (void)removeRulesObject:(DTComprehensiveRule *)value;
- (void)addRules:(NSSet *)values;
- (void)removeRules:(NSSet *)values;

@end

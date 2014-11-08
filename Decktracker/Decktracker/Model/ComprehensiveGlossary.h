//
//  ComprehensiveGlossary.h
//  Decktracker
//
//  Created by Jovit Royeca on 11/5/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ComprehensiveRule;

@interface ComprehensiveGlossary : NSManagedObject

@property (nonatomic, retain) NSString * definition;
@property (nonatomic, retain) NSString * term;
@property (nonatomic, retain) NSSet *rules;
@end

@interface ComprehensiveGlossary (CoreDataGeneratedAccessors)

- (void)addRulesObject:(ComprehensiveRule *)value;
- (void)removeRulesObject:(ComprehensiveRule *)value;
- (void)addRules:(NSSet *)values;
- (void)removeRules:(NSSet *)values;

@end

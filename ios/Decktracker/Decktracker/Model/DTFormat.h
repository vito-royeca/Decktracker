//
//  DTFormat.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTCardLegality;

@interface DTFormat : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *legalities;
@end

@interface DTFormat (CoreDataGeneratedAccessors)

- (void)addLegalitiesObject:(DTCardLegality *)value;
- (void)removeLegalitiesObject:(DTCardLegality *)value;
- (void)addLegalities:(NSSet *)values;
- (void)removeLegalities:(NSSet *)values;

@end

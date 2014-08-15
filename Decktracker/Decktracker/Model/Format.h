//
//  Format.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/14/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CardLegality;

@interface Format : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *legalities;
@end

@interface Format (CoreDataGeneratedAccessors)

- (void)addLegalitiesObject:(CardLegality *)value;
- (void)removeLegalitiesObject:(CardLegality *)value;
- (void)addLegalities:(NSSet *)values;
- (void)removeLegalities:(NSSet *)values;

@end

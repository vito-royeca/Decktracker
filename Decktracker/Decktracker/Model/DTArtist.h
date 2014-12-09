//
//  DTArtist.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTCard;

@interface DTArtist : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *cards;
@end

@interface DTArtist (CoreDataGeneratedAccessors)

- (void)addCardsObject:(DTCard *)value;
- (void)removeCardsObject:(DTCard *)value;
- (void)addCards:(NSSet *)values;
- (void)removeCards:(NSSet *)values;

@end

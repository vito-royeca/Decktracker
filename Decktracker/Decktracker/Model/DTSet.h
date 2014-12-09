//
//  DTSet.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTBlock, DTCard, DTSetType;

@interface DTSet : NSManagedObject

@property (nonatomic, retain) NSString * border;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * gathererCode;
@property (nonatomic, retain) NSNumber * imagesDownloaded;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfCards;
@property (nonatomic, retain) NSString * oldCode;
@property (nonatomic, retain) NSNumber * onlineOnly;
@property (nonatomic, retain) NSDate * releaseDate;
@property (nonatomic, retain) NSString * tcgPlayerName;
@property (nonatomic, retain) DTBlock *block;
@property (nonatomic, retain) NSSet *cards;
@property (nonatomic, retain) NSSet *printings;
@property (nonatomic, retain) DTSetType *type;
@end

@interface DTSet (CoreDataGeneratedAccessors)

- (void)addCardsObject:(DTCard *)value;
- (void)removeCardsObject:(DTCard *)value;
- (void)addCards:(NSSet *)values;
- (void)removeCards:(NSSet *)values;

- (void)addPrintingsObject:(DTCard *)value;
- (void)removePrintingsObject:(DTCard *)value;
- (void)addPrintings:(NSSet *)values;
- (void)removePrintings:(NSSet *)values;

@end

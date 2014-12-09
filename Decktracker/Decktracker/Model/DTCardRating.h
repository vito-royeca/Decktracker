//
//  DTCardRating.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTCard;

@interface DTCardRating : NSManagedObject

@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) DTCard *card;

@end

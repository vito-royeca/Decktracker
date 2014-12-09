//
//  DTCardLegality.h
//  Decktracker
//
//  Created by Jovit Royeca on 12/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTCard, DTFormat;

@interface DTCardLegality : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) DTCard *card;
@property (nonatomic, retain) DTFormat *format;

@end

//
//  Database.h
//  DeckTracker
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import Foundation;

#import "JJJ/JJJ.h"
#import "Card.h"
#import "CardRarity.h"

#define kFetchBatchSize       100
#define kDatabaseStore        @"decktracker.sqlite"

@interface Database : NSObject

+ (id)sharedInstance;

-(void) setupDb;
-(void) closeDb;

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
-(NSFetchedResultsController*) search:(NSString*)query;
-(NSFetchedResultsController*) search:(NSString*)query withPredicate:(NSPredicate*)predicate;
-(NSFetchedResultsController*) advanceSearch:(NSDictionary*)query withSorter:(NSDictionary*) sorter;
#endif

-(Card*) findCard:(NSString*) card inSet:(NSString*) setCode;
-(NSString*) cardRarityIndex:(Card*) card;

@end

//
//  Database.h
//  DeckTracker
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import Foundation;

#import "DTCard.h"
#import "DTCardRarity.h"

#import "JJJ/JJJ.h"

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
#import <Parse/Parse.h>
#endif

#define kFetchBatchSize         100
#define kDatabaseStore          @"decktracker.sqlite"

#define kFetchTopRatedDone      @"kFetchTopRatedDone"
#define kFetchTopViewedDone     @"kFetchTopViewedDone"
#define kParseSyncDone          @"kParseSyncDone"

@interface Database : NSObject

+ (id)sharedInstance;

-(void) setupDb;
-(void) closeDb;

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
-(NSFetchedResultsController*) search:(NSString*)query;
-(NSFetchedResultsController*) search:(NSString*)query withPredicate:(NSPredicate*)predicate;
-(NSFetchedResultsController*) advanceSearch:(NSDictionary*)query withSorter:(NSDictionary*) sorter;
#endif

-(DTCard*) findCard:(NSString*) card inSet:(NSString*) setCode;
-(NSString*) cardRarityIndex:(DTCard*) card;
-(DTCard*) fetchTcgPlayerPriceForCard:(DTCard*) card;
-(NSArray*) fetchRandomCards:(int) howMany;
-(NSArray*) fetchSets:(int) howMany;
-(NSArray*) fetchHighestPriced:(int) limit;

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
-(void) fetchTopRated:(int) limit skip:(int) skip;
-(void) fetchTopViewed:(int) limit skip:(int) skip;
-(void) incrementCardView:(DTCard*) card;
-(void) rateCard:(DTCard*) card for:(float) rating;
-(void) parseSynch:(DTCard*) card;
-(void) uploadAllSetsToParse;
#endif

@end

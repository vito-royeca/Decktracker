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
#import "Bolts.h"
#import <Parse/Parse.h>
#endif

#define kFetchBatchSize         100
#define kDatabaseStore          @"decktracker.sqlite"

#define kFetchTopRatedDone      @"kFetchTopRatedDone"
#define kFetchTopViewedDone     @"kFetchTopViewedDone"
#define kParseSyncDone          @"kParseSyncDone"
#define kPriceUpdateDone        @"kPriceUpdateDone"
#define kParseUserManaDone      @"kParseUserManaDone"

@interface Database : NSObject

+ (id)sharedInstance;

-(void) setupDb;
-(void) closeDb;

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
-(NSFetchedResultsController*) search:(NSString*) query
                  withSortDescriptors:(NSArray*) sorters
                      withSectionName:(NSString*) sectionName;

-(NSFetchedResultsController*) search:(NSString*)query
                        withPredicate:(NSPredicate*)predicate
                  withSortDescriptors:(NSArray*) sorters
                      withSectionName:(NSString*) sectionName;

-(NSFetchedResultsController*) advanceSearch:(NSDictionary*)query withSorter:(NSDictionary*) sorter;
#endif

-(DTCard*) findCard:(NSString*) card inSet:(NSString*) setCode;
-(DTCard*) findCardByMultiverseID:(NSString*) multiverseID;
-(NSString*) cardRarityIndex:(DTCard*) card;
-(void) fetchTcgPlayerPriceForCard:(DTCard*) card;
-(NSArray*) fetchRandomCards:(int) howMany withPredicate:(NSPredicate*) predicate;
-(NSArray*) fetchSets:(int) howMany;
-(BOOL) isCardModern:(DTCard*) card;
-(void) loadInAppSets;
-(NSDictionary*) inAppSettingsForSet:(DTSet*) set;
-(NSArray*) inAppSetCodes;
-(BOOL) isSetPurchased:(DTSet*) set;

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
-(void) fetchTopRated:(int) limit skip:(int) skip;
-(void) fetchTopViewed:(int) limit skip:(int) skip;
-(void) incrementCardView:(DTCard*) card;
-(void) rateCard:(DTCard*) card withRating:(float) rating;
//-(void) parseSynch:(DTCard*) card;
-(void) uploadAllSetsToParse;
-(void) prefetchAllSetObjects;
-(void) fetchUserMana;

#endif

@end

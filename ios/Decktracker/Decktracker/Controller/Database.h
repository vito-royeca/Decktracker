//
//  Database.h
//  DeckTracker
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import Foundation;

#import "DTArtist.h"
#import "DTBlock.h"
#import "DTCard.h"
#import "DTCardLEgality.h"
#import "DTCardRarity.h"
#import "DTCardRating.h"
#import "DTSet.h"
#import "DTSetType.h"

#import <JJJUtils/JJJ.h>

#import "Bolts.h"
#import <Parse/Parse.h>
#import <Realm/Realm.h>

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
#import "InAppPurchase.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#endif

#define kFetchBatchSize         100
#define kDatabaseStore          @"decktracker.realm"

#define kFetchTopRatedDone      @"kFetchTopRatedDone"
#define kFetchTopViewedDone     @"kFetchTopViewedDone"
#define kParseSyncDone          @"kParseSyncDone"
#define kPriceUpdateDone        @"kPriceUpdateDone"
#define kParseUserManaDone      @"kParseUserManaDone"
#define kParseLeaderboardDone   @"kParseLeaderboardDone"

@interface Database : NSObject

+ (id)sharedInstance;

#pragma mark - Setup
-(void) setupDb;
-(void) migrateDb;
-(void) closeDb;
-(void) copyRealmDatabaseToHome;
-(void) setupParse:(NSDictionary *)launchOptions;

#pragma mark - Finders
-(RLMResults*) findCards:(NSString*) query
     withSortDescriptors:(NSArray*) sorters
         withSectionName:(NSString*) sectionName;

-(RLMResults*) findCards:(NSString*)query
           withPredicate:(NSPredicate*)predicate
     withSortDescriptors:(NSArray*) sorters
         withSectionName:(NSString*) sectionName;

-(RLMResults*) advanceFindCards:(NSDictionary*)query
                    withSorters:(NSArray*) sorters;

-(NSArray*) fetchRandomCardsFromFormats:(NSArray*) formats
                         excludeFormats:(NSArray*) excludeFormats
                                howMany:(int) howMany;

-(void) fetchTcgPlayerPriceForCard:(NSString*) cardId;
-(NSArray*) fetchSets:(int) howMany;

#pragma mark - In App Purchase
#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
-(void) loadInAppSets;
-(NSDictionary*) inAppSettingsForSet:(NSString*) setId;
-(NSArray*) inAppSetCodes;
-(BOOL) isSetPurchased:(DTSet*) set;
-(NSArray*) fetchRandomCards:(int) howMany
               withPredicate:(NSPredicate*) predicate
        includeInAppPurchase:(BOOL) inAppPurchase;
#endif

#pragma mark - Parse methods
-(void) fetchTopRated:(int) limit skip:(int) skip;
-(void) fetchTopViewed:(int) limit skip:(int) skip;
-(void) incrementCardView:(NSString*) cardId;
-(void) rateCard:(NSString*) cardId withRating:(float) rating;
-(void) fetchCardRating:(NSString*) cardId;
-(void) fetchUserMana;
-(void) saveUserMana:(PFObject*) userMana;
-(void) deleteUserManaLocally;
-(void) fetchLeaderboard;

#pragma mark - Parse maintenance
-(void) transferCardsFromSet:(NSString*) sourceSetId toSet:(NSString*) destSetId;
-(void) deleteDuplicateParseCards;
-(void) updateParseCards;
-(void) uploadSets;
-(void) uploadArtists;
-(void) uploadBlocks;
-(void) uploadSetTypes;


@end

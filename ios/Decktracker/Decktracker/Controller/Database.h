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

#import <Realm/Realm.h>

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
#import "InAppPurchase.h"
#import "Bolts.h"
#import <Parse/Parse.h>
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

-(void) setupDb;
-(void) migrateDb;
-(void) closeDb;
-(void) copyRealmDatabaseToHome;
-(void) setupParse:(NSDictionary *)launchOptions;

-(RLMResults*) findCards:(NSString*) query
     withSortDescriptors:(NSArray*) sorters
         withSectionName:(NSString*) sectionName;

-(RLMResults*) findCards:(NSString*)query
           withPredicate:(NSPredicate*)predicate
     withSortDescriptors:(NSArray*) sorters
         withSectionName:(NSString*) sectionName;

-(RLMResults*) advanceFindCards:(NSDictionary*)query
                    withSorters:(NSArray*) sorters;

-(void) loadInAppSets;
-(NSDictionary*) inAppSettingsForSet:(NSString*) setId;
-(NSArray*) inAppSetCodes;
-(BOOL) isSetPurchased:(DTSet*) set;
-(NSArray*) fetchRandomCards:(int) howMany
               withPredicate:(NSPredicate*) predicate
        includeInAppPurchase:(BOOL) inAppPurchase;
-(NSArray*) fetchRandomCardsFromFormats:(NSArray*) formats
                         excludeFormats:(NSArray*) excludeFormats
                                howMany:(int) howMany;

-(DTCard*) findCard:(NSString*) card inSet:(NSString*) setCode;
-(DTCard*) findCardByMultiverseID:(NSString*) multiverseID;
-(void) fetchTcgPlayerPriceForCard:(NSString*) cardId;
-(NSArray*) fetchSets:(int) howMany;

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
-(void) fetchTopRated:(int) limit skip:(int) skip;
-(void) fetchTopViewed:(int) limit skip:(int) skip;
-(void) incrementCardView:(NSString*) cardId;
-(void) rateCard:(NSString*) cardId withRating:(float) rating;
-(void) fetchCardRating:(NSString*) cardId;
-(void) fetchUserMana;
-(void) saveUserMana:(PFObject*) userMana;
-(void) deleteUserManaLocally;
-(void) fetchLeaderboard;
// Parse Maintenance
-(void) updateParseCards;
-(void) deleteDuplicateParseCards;
-(void) uploadArtists;
-(void) uploadBlocks;
-(void) uploadSetTypes;
-(void) uploadSets;
#endif

@end

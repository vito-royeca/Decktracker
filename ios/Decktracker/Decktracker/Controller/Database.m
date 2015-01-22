//
//  Database.m
//  DeckTracker
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "Database.h"
#import "DTCardRating.h"
#import "DTSet.h"
#import "InAppPurchase.h"
#import "Magic.h"

#import "TFHpple.h"

@implementation Database
{
    NSMutableArray *_parseQueue;
    NSArray *_currentParseQueue;
    NSDate *_8thEditionReleaseDate;
    NSMutableArray *_arrInAppSets;
}

static Database *_me;

+(id) sharedInstance
{
    if (!_me)
    {
        _me = [[Database alloc] init];
    }
    
    return _me;
}

-(id) init
{
    if (self = [super init])
    {
        _parseQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) setupDb
{
#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"decktracker.plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    NSString *jsonVersion = [dict objectForKey:@"JSON Version"];
    NSString *imagesVersion = [dict objectForKey:@"Images Version"];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *storePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", kDatabaseStore]];
    
    NSDictionary *arrCardUpdates = [dict objectForKey:@"Card Updates"];
    NSArray *sortedKeys = [[arrCardUpdates allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (NSString *ver in sortedKeys)
    {
        for (NSString *setCode in arrCardUpdates[ver])
        {
            NSString *key = [NSString stringWithFormat:@"%@-%@", ver, setCode];
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:key])
            {
                NSString *path = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/card/%@/", setCode]];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil])
                    {
                        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", path, file] error:nil];
                    }
                }
                
                path = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/crop/%@/", setCode]];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil])
                    {
                        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", path, file] error:nil];
                    }
                }
            }
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:storePath])
    {
        NSString *preloadPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], kDatabaseStore];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtPath:preloadPath toPath:storePath error:&err])
        {
            NSLog(@"Error: Unable to copy preloaded database.");
        }
        [[NSUserDefaults standardUserDefaults] setValue:jsonVersion forKey:@"JSON Version"];
        [[NSUserDefaults standardUserDefaults] setValue:imagesVersion forKey:@"Images Version"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSString *currentJSONVersion = [[NSUserDefaults standardUserDefaults] valueForKey:@"JSON Version"];
        
        if (!currentJSONVersion || ![jsonVersion isEqualToString:currentJSONVersion])
        {
            for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:nil])
            {
                if ([file hasPrefix:@"decktracker."])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]]
                                                               error:nil];
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setValue:jsonVersion forKey:@"JSON Version"];
            [[NSUserDefaults standardUserDefaults] setValue:imagesVersion forKey:@"Images Version"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setupDb];
        }
    }
#endif
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kDatabaseStore];
    DTSet *set = [DTSet MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"name == %@", @"Eighth Edition"]];
    _8thEditionReleaseDate = set.releaseDate;
    [self loadInAppSets];
    
    


#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:nil])
    {
        if ([file hasPrefix:@"decktracker."])
        {
            NSURL *url = [[NSURL alloc] initFileURLWithPath:[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]]];
            [JJJUtil addSkipBackupAttributeToItemAtURL:url];
        }
    }
#endif

}

-(void) closeDb
{
    [MagicalRecord cleanUp];
}

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
-(NSFetchedResultsController*) search:(NSString*) query
                  withSortDescriptors:(NSArray*) sorters
                      withSectionName:(NSString*) sectionName
{
    NSPredicate *predicate;
    
    if (query.length == 0)
    {
        return nil;
    }
    else if (query.length == 1)
    {
        predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[cd] %@", @"name", query];
    }
    else
    {
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"name", query];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"type", query];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"text", query];
        NSPredicate *pred4 = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"flavor", query];
        predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred1, pred2, pred3, pred4]];
    }
    
    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    if (!sorters)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                        ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"set.releaseDate"
                                                                        ascending:NO];
        
        sorters = @[sortDescriptor1, sortDescriptor2];
    }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DTCard"
                                              inManagedObjectContext:moc];
    
    // to do: exclude In-App Sets
    NSArray *inAppSetCodes = [self inAppSetCodes];
    if (inAppSetCodes.count > 0)
    {
        NSPredicate *predInAppSets = [NSPredicate predicateWithFormat:@"NOT (set.code IN %@)", inAppSetCodes];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predInAppSets]];
    }
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sorters];
    [fetchRequest setFetchBatchSize:kFetchBatchSize];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:moc
                                                 sectionNameKeyPath:sectionName
                                                          cacheName:nil];
}

-(NSFetchedResultsController*) search:(NSString*) query
                        withPredicate:(NSPredicate*)predicate
                  withSortDescriptors:(NSArray*) sorters
                      withSectionName:(NSString*) sectionName
{
    NSPredicate *predicate2;
    
    if (query.length > 0)
    {
        if (query.length == 1)
        {
            NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[cd] %@", @"name", query];
            if (predicate)
            {
                predicate2 = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, pred1]];
            }
            else
            {
                predicate2 = pred1;
            }
        }
        else
        {
            NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"name", query];
            if (predicate)
            {
                predicate2 = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, pred1]];
            }
            else
            {
                predicate2 = pred1;
            }
        }
    }
    
    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    if (!sorters)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                        ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"set.releaseDate"
                                                                        ascending:NO];
        
        sorters = @[sortDescriptor1, sortDescriptor2];
    }
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DTCard"
                                              inManagedObjectContext:moc];
    
    
    NSPredicate *pred = predicate2 ? predicate2 : predicate;
    // to do: exclude In-App Sets
    NSArray *inAppSetCodes = [self inAppSetCodes];
    if (inAppSetCodes.count > 0)
    {
        NSPredicate *predInAppSets = [NSPredicate predicateWithFormat:@"NOT (set.code IN %@)", inAppSetCodes];
        pred = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred, predInAppSets]];
    }
    
    [fetchRequest setPredicate:pred];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sorters];
    [fetchRequest setFetchBatchSize:kFetchBatchSize];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:moc
                                                 sectionNameKeyPath:sectionName
                                                          cacheName:nil];
}

-(NSFetchedResultsController*) advanceSearch:(NSDictionary*)query withSorter:(NSDictionary*) sorter
{
    NSPredicate *predicate;
    
    for (NSString *key in [query allKeys])
    {
        NSString *fieldName;
        BOOL bToMany = NO;
        BOOL bExact = NO;
        
        if ([key isEqualToString:@"Name"])
        {
            fieldName = @"name";
        }
        else if ([key isEqualToString:@"Set"])
        {
            fieldName = @"set.name";
//            bToMany = YES;
            bExact = YES;
        }
        else if ([key isEqualToString:@"Rarity"])
        {
            fieldName = @"rarity.name";
//            bToMany = YES;
            bExact = YES;
        }
        else if ([key isEqualToString:@"Type"])
        {
            fieldName = @"types.name";
//            bToMany = YES;
            bExact = YES;
        }
        else if ([key isEqualToString:@"Subtype"])
        {
            fieldName = @"subTypes.name";
//            bToMany = YES;
            bExact = YES;
        }
        else if ([key isEqualToString:@"Color"])
        {
            fieldName = @"sectionColor";
        }
        else if ([key isEqualToString:@"Keyword"])
        {
            fieldName = @"text";
        }
        else if ([key isEqualToString:@"Text"])
        {
            fieldName = @"originalText";
        }
        else if ([key isEqualToString:@"Flavor Text"])
        {
            fieldName = @"flavor";
        }
        else if ([key isEqualToString:@"Artist"])
        {
            fieldName = @"artist.name";
//            bToMany = YES;
            bExact = YES;
        }
        else if ([key isEqualToString:@"Will Be Reprinted?"])
        {
            fieldName = @"reserved";
        }
        
        for (NSDictionary *dict in query[key])
        {
            NSPredicate *pred;
            NSString *condition = [[dict allKeys] firstObject];
            NSString *stringValue = [[dict allValues] firstObject];
            
            if ([key isEqualToString:@"Color"])
            {
                pred = [NSPredicate predicateWithFormat:@"%K == %@", fieldName, stringValue];
            }
            
            else if ([key isEqualToString:@"Will Be Reprinted?"])
            {
                NSNumber *reserved;
                
                if ([stringValue isEqualToString:@"Yes"])
                {
                    reserved = [NSNumber numberWithBool:NO];
                }
                else
                {
                    reserved = [NSNumber numberWithBool:YES];
                }
                
                pred = [NSPredicate predicateWithFormat:@"%K == %@", fieldName, reserved];
            }
            
            if (!pred)
            {
                if (stringValue)
                {
                    if (bToMany)
                    {
                        pred = [NSPredicate predicateWithFormat:@"ANY %K == [cd] %@", fieldName, stringValue];
                    }
                    else
                    {
                        if (bExact)
                        {
                            pred = [NSPredicate predicateWithFormat:@"ANY %K == [cd] %@", fieldName, stringValue];
                        }
                        else
                        {
                            if (stringValue.length == 1)
                            {
                                pred = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[cd] %@", fieldName, stringValue];
                            }
                            else
                            {
                                pred = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", fieldName, stringValue];
                            }
                        }
                    }
                }
                else
                {
                    if (bToMany)
                    {
                        pred = [NSPredicate predicateWithFormat:@"ANY %K = nil", fieldName];
                    }
                    else
                    {
                        pred = [NSPredicate predicateWithFormat:@"%K = nil", fieldName];
                    }
                }
            }
            
            if ([condition isEqualToString:@"And"])
            {
                predicate = predicate ? [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, pred]] : pred;
            }
            else if ([condition isEqualToString:@"Or"])
            {
                predicate = predicate ? [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate, pred]] : pred;
            }
            else if ([condition isEqualToString:@"Not"])
            {
                predicate = predicate ? [NSCompoundPredicate notPredicateWithSubpredicate:pred] : pred;
            }
        }
    }
    
    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"set.releaseDate"
                                                                    ascending:NO];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DTCard"
                                              inManagedObjectContext:moc];
    
    // to do: exclude In-App Sets
    NSArray *inAppSetCodes = [self inAppSetCodes];
    if (inAppSetCodes.count > 0)
    {
        NSPredicate *predInAppSets = [NSPredicate predicateWithFormat:@"NOT (set.code IN %@)", inAppSetCodes];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predInAppSets]];
    }
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
    [fetchRequest setFetchBatchSize:kFetchBatchSize];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:moc
                                                 sectionNameKeyPath:nil
                                                          cacheName:nil];
}
#endif

-(DTCard*) findCard:(NSString*) cardName inSet:(NSString*) setCode
{
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"name == %@", cardName];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"set.code == %@", setCode];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred1, pred2]];
    
    // to do: exclude In-App Sets
    NSArray *inAppSetCodes = [self inAppSetCodes];
    if (inAppSetCodes.count > 0)
    {
        NSPredicate *predInAppSets = [NSPredicate predicateWithFormat:@"NOT (set.code IN %@)", inAppSetCodes];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predInAppSets]];
    }
    return [DTCard MR_findFirstWithPredicate:predicate];
}

-(DTCard*) findCardByMultiverseID:(NSString*) multiverseID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"multiverseID == %@", multiverseID];
    
    // to do: exclude In-App Sets
    NSArray *inAppSetCodes = [self inAppSetCodes];
    if (inAppSetCodes.count > 0)
    {
        NSPredicate *predInAppSets = [NSPredicate predicateWithFormat:@"NOT (set.code IN %@)", inAppSetCodes];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predInAppSets]];
    }
    
    return [DTCard MR_findFirstWithPredicate:predicate];
}

-(NSString*) cardRarityIndex:(DTCard*) card
{
    return [card.rarity.name isEqualToString:@"Basic Land"] ? @"C" : [[card.rarity.name substringToIndex:1] uppercaseString];
}

-(void) fetchTcgPlayerPriceForCard:(DTCard*) card
{
    BOOL bWillFetch = NO;
    
    if (!card.tcgPlayerFetchDate)
    {
        bWillFetch = YES;
    }
    else
    {
        NSDate *today = [NSDate date];
        
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components:NSCalendarUnitHour
                                                    fromDate:card.tcgPlayerFetchDate
                                                      toDate:today
                                                     options:0];
        
        if ([components hour] >= TCGPLAYER_FETCH_STORAGE)
        {
            bWillFetch = YES;
        }
    }
    
    if (!card.set.tcgPlayerName)
    {
        bWillFetch = NO;
    }
    
    if (bWillFetch)
    {
#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
#endif

#ifdef DEBUG
            NSLog(@"Fetching price for %@ (%@)", card.name, card.set.code);
#endif

            NSString *tcgPricing = [[NSString stringWithFormat:@"http://partner.tcgplayer.com/x3/phl.asmx/p?pk=%@&s=%@&p=%@", TCGPLAYER_PARTNER_KEY, card.set.tcgPlayerName, card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (!card.set.tcgPlayerName)
            {
                tcgPricing = [[NSString stringWithFormat:@"http://partner.tcgplayer.com/x3/phl.asmx/p?pk=%@&p=%@", TCGPLAYER_PARTNER_KEY, card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:tcgPricing]];
            TFHpple *parser = [TFHpple hppleWithHTMLData:data];
            NSString *low, *mid, *high, *foil, *link;
            
            NSArray *nodes = [parser searchWithXPathQuery:@"//product"];
            for (TFHppleElement *element in nodes)
            {
                if ([element hasChildren])
                {
                    BOOL linkIsNext = NO;
                    
                    for (TFHppleElement *child in element.children)
                    {
                        if ([[child tagName] isEqualToString:@"hiprice"])
                        {
                            high = [[child firstChild] content];
                        }
                        else if ([[child tagName] isEqualToString:@"avgprice"])
                        {
                            mid = [[child firstChild] content];
                        }
                        else if ([[child tagName] isEqualToString:@"lowprice"])
                        {
                            low = [[child firstChild] content];
                        }
                        else if ([[child tagName] isEqualToString:@"foilavgprice"])
                        {
                            foil = [[child firstChild] content];
                        }
                        else if ([[child tagName] isEqualToString:@"link"])
                        {
                            linkIsNext = YES;
                        }
                        else if ([[child tagName] isEqualToString:@"text"] && linkIsNext)
                        {
                            link = [child content];
                        }
                    }
                }
            }
            
            card.tcgPlayerHighPrice = high ? [NSNumber numberWithDouble:[high doubleValue]] : card.tcgPlayerHighPrice;
            card.tcgPlayerMidPrice  = mid  ? [NSNumber numberWithDouble:[mid doubleValue]]  : card.tcgPlayerMidPrice;
            card.tcgPlayerLowPrice  = low  ? [NSNumber numberWithDouble:[low doubleValue]]  : card.tcgPlayerLowPrice;
            card.tcgPlayerFoilPrice = foil ? [NSNumber numberWithDouble:[foil doubleValue]] : card.tcgPlayerFoilPrice;
            card.tcgPlayerLink = link ? [JJJUtil trim:link] : card.tcgPlayerLink;
            card.tcgPlayerFetchDate = [NSDate date];
            
            NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_defaultContext];
            if ([currentContext hasChanges])
            {
                [currentContext MR_saveToPersistentStoreAndWait];
            }
            
#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
            dispatch_async(dispatch_get_main_queue(), ^{
#endif
                [[NSNotificationCenter defaultCenter] postNotificationName:kPriceUpdateDone
                                                                    object:nil
                                                                  userInfo:@{@"card": card}];
#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
            });
        });
#endif
    }
}

-(NSArray*) fetchRandomCards:(int) howMany
{
    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                    ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"set.releaseDate"
                                                                    ascending:NO];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DTCard"
                                              inManagedObjectContext:moc];
    
    [fetchRequest setEntity:entity];
    NSUInteger count = [moc countForFetchRequest:fetchRequest error:NULL];
    NSMutableArray *arrIDs = [[NSMutableArray alloc] initWithCapacity:howMany];
    NSArray *array = [[NSMutableArray alloc] init];
    
    if (count > 0)
    {
        for (int i=0; i<howMany; i++)
        {
            [arrIDs addObject:[NSNumber numberWithInt:arc4random()%count]];
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cardID IN(%@)", arrIDs];
        
        // to do: exclude In-App Sets
        NSArray *inAppSetCodes = [self inAppSetCodes];
        if (inAppSetCodes.count > 0)
        {
            NSPredicate *predInAppSets = [NSPredicate predicateWithFormat:@"NOT (set.code IN %@)", inAppSetCodes];
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predInAppSets]];
        }
        
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
        [fetchRequest setFetchLimit:howMany];
        
        NSError *error = nil;
        array = [moc executeFetchRequest:fetchRequest error:&error];
    }
    
    return array;
}

-(NSArray*) fetchSets:(int) howMany
{
    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"releaseDate"
                                                                    ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                    ascending:YES];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DTSet"
                                              inManagedObjectContext:moc];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
    [fetchRequest setFetchLimit:howMany];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:fetchRequest error:&error];
    return array;
}

-(BOOL) isCardModern:(DTCard*) card
{
    NSDate *releaseDate;
    
    if (card.releaseDate)
    {
        NSString *format = @"YYYY-MM-dd";
        NSString *tempReleaseDate;
        
        if (card.releaseDate.length == 4)
        {
            tempReleaseDate = [NSString stringWithFormat:@"%@-01-01", card.releaseDate];
        }
        else if (card.releaseDate.length == 7)
        {
            tempReleaseDate = [NSString stringWithFormat:@"%@-01", card.releaseDate];
        }
        releaseDate = [JJJUtil parseDate:(tempReleaseDate ? tempReleaseDate : card.releaseDate)
                              withFormat:format];
    }
    else
    {
        releaseDate = card.set.releaseDate;
    }
    return [releaseDate compare:_8thEditionReleaseDate] == NSOrderedSame ||
        [releaseDate compare:_8thEditionReleaseDate] == NSOrderedDescending;
}

-(void) loadInAppSets
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"In-App Sets.plist"];
    _arrInAppSets = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in [NSArray arrayWithContentsOfFile:filePath])
    {
        if (![InAppPurchase isProductPurchased:dict[@"In-App Product ID"]])
        {
            [_arrInAppSets addObject:dict];
        }
    }
}

-(NSDictionary*) inAppSettingsForSet:(DTSet*) set
{
    for (NSDictionary *dict in _arrInAppSets)
    {
        if ([dict[@"Name"] isEqualToString:set.name] &&
            [dict[@"Code"] isEqualToString:set.code])
        {
            return dict;
        }
    }
    return nil;
}

-(NSArray*) inAppSetCodes
{
    NSMutableArray *arrSetCodes = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in _arrInAppSets) {
        [arrSetCodes addObject:dict[@"Code"]];
    }
    
    return arrSetCodes;
}

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
-(void) fetchTopRated:(int) limit skip:(int) skip
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rating >= 0"];
    PFQuery *query = [PFQuery queryWithClassName:@"Card" predicate:predicate];
    [query orderByDescending:@"rating"];
    [query addAscendingOrder:@"name"];
    [query includeKey:@"set"];

    if (limit >= 0)
    {
        query.limit = limit;
    }
    query.limit = limit;
    if (skip >= 0)
    {
        query.skip = skip;
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        NSMutableArray *arrResults = [[NSMutableArray alloc] init];
        NSManagedObjectContext *moc = [NSManagedObjectContext MR_contextForCurrentThread];
        
        if (!error)
        {
            for (PFObject *object in objects)
            {
                NSPredicate *p = [NSPredicate predicateWithFormat:@"(%K = %@ AND %K = %@ AND %K = %@)", @"name", object[@"name"], @"multiverseID", object[@"multiverseID"], @"set.name", object[@"set"][@"name"]];
                DTCard *card = [DTCard MR_findFirstWithPredicate:p];
                
                card.rating = object[@"rating"];
                if ([moc hasChanges])
                {
                    [moc MR_saveToPersistentStoreAndWait];
                }
                [arrResults addObject:card];
            }
        }
        else
        {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"rating"
                                                                            ascending:NO];
            NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                            ascending:YES];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"DTCard"
                                                      inManagedObjectContext:moc];
            
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"rating >= 0"]];
            [fetchRequest setEntity:entity];
            [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
            [fetchRequest setFetchLimit:limit];
            
            NSError *error = nil;
            [arrResults addObjectsFromArray:[moc executeFetchRequest:fetchRequest error:&error]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kFetchTopRatedDone
                                                            object:nil
                                                          userInfo:@{@"data": arrResults}];
    }];
}

-(void) fetchTopViewed:(int) limit skip:(int) skip
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOfViews >= 0"];
    PFQuery *query = [PFQuery queryWithClassName:@"Card" predicate:predicate];
    [query orderByDescending:@"numberOfViews"];
    [query addAscendingOrder:@"name"];
    [query includeKey:@"set"];

    if (limit >= 0)
    {
        query.limit = limit;
    }
    query.limit = limit;
    if (skip >= 0)
    {
        query.skip = skip;
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        NSMutableArray *arrResults = [[NSMutableArray alloc] init];
        
        if (!error)
        {
            for (PFObject *object in objects)
            {
                NSPredicate *p = [NSPredicate predicateWithFormat:@"(%K = %@ AND %K = %@ AND %K = %@)", @"name", object[@"name"], @"multiverseID", object[@"multiverseID"], @"set.name", object[@"set"][@"name"]];
                DTCard *card = [DTCard MR_findFirstWithPredicate:p];
                
                [arrResults addObject:card];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kFetchTopViewedDone
                                                            object:nil
                                                          userInfo:@{@"data": arrResults}];
    }];
}

-(void) processCurrentParseQueue
{
    DTCard *card = _currentParseQueue[0];
    void (^callbackTask)(PFObject *pfCard) = _currentParseQueue[1];
    
    void (^callbackFindCard)(NSString *cardName, NSNumber *multiverseID, PFObject *pfSet) = ^void(NSString *cardName, NSNumber *multiverseID, PFObject *pfSet)
    {
        __block PFQuery *query = [PFQuery queryWithClassName:@"Card"];
        [query whereKey:@"name" equalTo:cardName];
        [query whereKey:@"multiverseID" equalTo:multiverseID];
        [query whereKey:@"set" equalTo:pfSet];
        [query fromLocalDatastore];
        
        [[query findObjectsInBackground] continueWithBlock:^id(BFTask *task)
        {
            if (task.error)
            {
                return task;
            }
           
            __block PFObject *pfCard;
            
            for (PFObject *object in task.result)
            {
                pfCard = object;
            }
            
            if (pfCard)
            {
                callbackTask(pfCard);
            }
            else
            {
                // not found in local datastore, find remotely
                query = [PFQuery queryWithClassName:@"Card"];
                [query whereKey:@"name" equalTo:cardName];
                [query whereKey:@"multiverseID" equalTo:multiverseID];
                [query whereKey:@"set" equalTo:pfSet];
                
                [[query findObjectsInBackground] continueWithSuccessBlock:^id(BFTask *task)
                 {
                    return [[PFObject unpinAllObjectsInBackgroundWithName:@"Cards"] continueWithSuccessBlock:^id(BFTask *ignored)
                    {
                        NSArray *results = task.result;
                        
                        if (results.count > 0)
                        {
                            pfCard = task.result[0];
                        }
                        else
                        {
                            // not found remotely
                            pfCard = [PFObject objectWithClassName:@"Card"];
                            pfCard[@"name"] = cardName;
                            pfCard[@"multiverseID"] = multiverseID;
                            pfCard[@"set"] = pfSet;
                        }
                        
                        [pfCard pinInBackgroundWithBlock:^(BOOL success, NSError *error) {
                            callbackTask(pfCard);
                        }];
                        return nil;
                    }];
                 }];
            }
            
            return task;
         }];
    };
    
    void (^callbackFindSet)(NSString *setName, NSString *setCode, NSString *cardName, NSNumber *multiverseID) = ^void(NSString *setName, NSString *setCode, NSString *cardName, NSNumber *multiverseID)
    {
        __block PFQuery *query = [PFQuery queryWithClassName:@"Set"];
        [query whereKey:@"name" equalTo:setName];
        [query whereKey:@"code" equalTo:setCode];
        [query fromLocalDatastore];
        
        [[query findObjectsInBackground] continueWithBlock:^id(BFTask *task)
         {
             __block PFObject *pfSet;
             
             if (task.error)
             {
                 return task;
             }
             
             for (PFObject *object in task.result)
             {
                 pfSet = object;
             }
             
             if (pfSet)
             {
                 callbackFindCard(cardName, multiverseID, pfSet);
             }
             else
             {
                 // not found in local datastore, find remotely
                 query = [PFQuery queryWithClassName:@"Set"];
                 [query whereKey:@"name" equalTo:setName];
                 [query whereKey:@"code" equalTo:setCode];
                 
                 [[query findObjectsInBackground] continueWithSuccessBlock:^id(BFTask *task)
                  {
                      return [[PFObject unpinAllObjectsInBackgroundWithName:@"Sets"] continueWithSuccessBlock:^id(BFTask *ignored)
                      {
                          NSArray *results = task.result;
                                  
                          if (results.count > 0)
                          {
                              pfSet = task.result[0];
                          }
                          else
                          {
                              // not found remotely
                              pfSet = [PFObject objectWithClassName:@"Set"];
                              pfSet[@"name"] = setName;
                              pfSet[@"code"] = setCode;
                          }
                                  
                          [pfSet pinInBackgroundWithBlock:^(BOOL success, NSError *error)
                          {
                               callbackFindCard(cardName, multiverseID, pfSet);
                          }];
                          return nil;
                      }];
                  }];
             }
             
             return task;
         }];
    };
    
    callbackFindSet(card.set.name, card.set.code, card.name, card.multiverseID);
}

-(void) processQueue
{
    if (_parseQueue.count == 0 || _currentParseQueue)
    {
        return;
    }
    
    _currentParseQueue = [_parseQueue objectAtIndex:0];
    [_parseQueue removeObject:_currentParseQueue];
    [self processCurrentParseQueue];
}

-(void) incrementCardView:(DTCard*) card
{
    void (^callbackIncrementCard)(PFObject *pfCard) = ^void(PFObject *pfCard) {
        [pfCard incrementKey:@"numberOfViews"];
        
        [pfCard saveEventually:^(BOOL success, NSError *error) {
            NSManagedObjectContext *moc = [NSManagedObjectContext MR_contextForCurrentThread];
            card.rating = pfCard[@"rating"];
            [moc MR_saveToPersistentStoreAndWait];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kParseSyncDone
                                                                object:nil
                                                              userInfo:@{@"card": card}];
            _currentParseQueue = nil;
            [self processQueue];
        }];
    };
    
    [_parseQueue addObject:@[card, callbackIncrementCard]];
    [self processQueue];
}

-(void) rateCard:(DTCard*) card withRating:(float) rating
{
    void (^callbackRateCard)(PFObject *pfCard) = ^void(PFObject *pfCard) {
        PFObject *pfRating = [PFObject objectWithClassName:@"CardRating"];
        pfRating[@"rating"] = [NSNumber numberWithDouble:rating];
        pfRating[@"card"] = pfCard;
        
        [pfRating saveEventually:^(BOOL success, NSError *error) {
            PFQuery *query = [PFQuery queryWithClassName:@"CardRating"];
            [query whereKey:@"card" equalTo:pfCard];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSManagedObjectContext *moc = [NSManagedObjectContext MR_contextForCurrentThread];
                double totalRating = 0;
                double averageRating = 0;
                
                for (PFObject *object in objects)
                {
                    DTCardRating *rating = [DTCardRating MR_createEntity];
                    rating.rating = object[@"rating"];
                    rating.card = card;
                    [moc MR_saveToPersistentStoreAndWait];
                    
                    totalRating += [object[@"rating"] doubleValue];
                }
                
                averageRating = totalRating/objects.count;
                if (isnan(averageRating))
                {
                    averageRating = 0;
                }
                
                pfCard[@"rating"] = [NSNumber numberWithDouble:averageRating];
                [pfCard saveEventually:^(BOOL success, NSError *error) {
                    card.rating = [NSNumber numberWithDouble:averageRating];
                    [moc MR_saveToPersistentStoreAndWait];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kParseSyncDone
                                                                        object:nil
                                                                      userInfo:@{@"card": card}];
                    _currentParseQueue = nil;
                    [self processQueue];
                }];
            }];
        }];
    };
    
    [_parseQueue addObject:@[card, callbackRateCard]];
    [self processQueue];
}

//-(void) parseSynch:(DTCard*) card
//{
//    void (^callbackParseSynchCard)(PFObject *pfCard) = ^void(PFObject *pfCard) {
//        PFQuery *query = [PFQuery queryWithClassName:@"CardRating"];
//        [query whereKey:@"card" equalTo:pfCard];
//        
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            NSManagedObjectContext *moc = [NSManagedObjectContext MR_contextForCurrentThread];
//            double totalRating = 0;
//            double averageRating = 0;
//            
//            for (PFObject *object in objects)
//            {
//                DTCardRating *rating = [DTCardRating MR_createEntity];
//                rating.rating = object[@"rating"];
//                rating.card = card;
//                [moc MR_saveToPersistentStoreAndWait];
//                
//                totalRating += [object[@"rating"] doubleValue];
//            }
//            averageRating = totalRating/objects.count;
//            if (isnan(averageRating))
//            {
//                averageRating = 0;
//            }
//            
//            pfCard[@"rating"] = [NSNumber numberWithDouble:averageRating];
//            [pfCard saveEventually:^(BOOL success, NSError *error) {
//                card.rating = [NSNumber numberWithDouble:averageRating];
//                [moc MR_saveToPersistentStoreAndWait];
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:kParseSyncDone
//                                                                    object:nil
//                                                                  userInfo:@{@"card": card}];
//                _currentParseQueue = nil;
//                [self processQueue];
//            }];
//        }];
//    };
//    
//    [_parseQueue addObject:@[card, callbackParseSynchCard]];
//    [self processQueue];
//}

-(void) uploadAllSetsToParse
{
    for (DTSet *set in [DTSet MR_findAllSortedBy:@"name" ascending:YES])
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Set"];
        [query whereKey:@"name" equalTo:set.name];
        [query whereKey:@"code" equalTo:set.code];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (objects.count == 0)
            {
                PFObject *pfSet = [PFObject objectWithClassName:@"Set"];
                pfSet[@"name"] = set.name;
                pfSet[@"code"] = set.code;
                [pfSet saveEventually:^(BOOL succeeded, NSError *error) {
                    NSLog(@"Uploaded: %@ - %@", set.name, set.code);
                }];
            }
        }];
    }
}

-(void) prefetchAllSetObjects
{
    PFQuery *query = [PFQuery queryWithClassName:@"Set"];
    NSDate *localDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"PFSets.updatedAt"];
    __block NSDate *remoteDate;
    __block BOOL bWillFetch = localDate == nil;
    
    if (!bWillFetch)
    {
        [query orderByDescending:@"updatedAt"];
        [query setLimit:1];
        
        [[query findObjectsInBackground] continueWithSuccessBlock:^id(BFTask *task)
        {
            PFObject *latestSet = task.result[0];
            remoteDate = latestSet.updatedAt;
            [[NSUserDefaults standardUserDefaults] setObject:remoteDate forKey:@"PFSets.updatedAt"];
            bWillFetch = [localDate compare:remoteDate] == NSOrderedAscending;
    
            if (bWillFetch)
            {
                PFQuery *q = [PFQuery queryWithClassName:@"Set"];
                [q orderByDescending:@"updatedAt"];
                [q setLimit:200];
                
                // Query from the network
                [[q findObjectsInBackground] continueWithSuccessBlock:^id(BFTask *task)
                 {
                     return [[PFObject unpinAllObjectsInBackgroundWithName:@"AllSets"] continueWithSuccessBlock:^id(BFTask *ignored)
                     {
                         PFObject *latestSet = task.result[0];
                         remoteDate = latestSet.updatedAt;
                         [[NSUserDefaults standardUserDefaults] setObject:remoteDate forKey:@"PFSets.updatedAt"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                                 
                         NSArray *pfSets = task.result;
                         return [PFObject pinAllInBackground:pfSets withName:@"AllSets"];
                     }];
                 }];
            }
            
            else
            {
                // Query for from locally
                PFQuery *q = [PFQuery queryWithClassName:@"Set"];
                [q orderByAscending:@"name"];
                [q setLimit:200];
                [q fromLocalDatastore];
                
                [[q findObjectsInBackground] continueWithBlock:^id(BFTask *task)
                {
                    if (task.error)
                    {
                        return task;
                    }
                     
                    return task;
                }];
            }
            
            return nil;
        }];
    }
}

#endif

@end

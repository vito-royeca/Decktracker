//
//  Database.m
//  DeckTracker
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "Database.h"
#import "Constants.h"

#import "TFHpple.h"

@implementation Database
{
    NSMutableArray *_parseQueue;
    NSArray *_currentParseQueue;
    NSDate *_8thEditionReleaseDate;
    NSMutableArray *_arrInAppSets;
}

static Database *_me;

#pragma mark: Setup code
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
    
//    NSDictionary *arrCardUpdates = [dict objectForKey:@"Card Updates"];
//    NSArray *sortedKeys = [[arrCardUpdates allKeys] sortedArrayUsingSelector: @selector(compare:)];
//    for (NSString *ver in sortedKeys)
//    {
//        for (NSString *setCode in arrCardUpdates[ver])
//        {
//            NSString *key = [NSString stringWithFormat:@"%@-%@", ver, setCode];
//            
//            if (![[NSUserDefaults standardUserDefaults] boolForKey:key])
//            {
//                NSString *path = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/card/%@/", setCode]];
//                
//                if ([[NSFileManager defaultManager] fileExistsAtPath:path])
//                {
//                    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil])
//                    {
//                        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", path, file] error:nil];
//                    }
//                }
//                
//                path = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/crop/%@/", setCode]];
//                
//                if ([[NSFileManager defaultManager] fileExistsAtPath:path])
//                {
//                    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil])
//                    {
//                        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", path, file] error:nil];
//                    }
//                }
//            }
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
//        }
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    
    // delete all cards from mtgimage.com
    NSString *mtgImageKey = @"mtgimage.com images";
    if (![[NSUserDefaults standardUserDefaults] boolForKey:mtgImageKey])
    {
        NSString *path = [cachePath stringByAppendingPathComponent:@"/images/card"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }

        path = [cachePath stringByAppendingPathComponent:@"/images/crop"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:mtgImageKey];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:storePath])
    {
        NSString *preloadPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], kDatabaseStore];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtPath:preloadPath toPath:storePath error:&err])
        {
            NSLog(@"Error: Unable to copy preloaded database.");
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setValue:jsonVersion forKey:@"JSON Version"];
            [[NSUserDefaults standardUserDefaults] setValue:imagesVersion forKey:@"Images Version"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
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
    
    // delete core data files
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:nil])
    {
        if ([file hasSuffix:@"sqlite"] ||
            [file hasSuffix:@"sqlite-shm"] ||
            [file hasSuffix:@"sqlite-wal"])
        {
            [[NSFileManager defaultManager] removeItemAtPath:[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]]
                                                       error:nil];
        }
    }
    
    [RLMRealm setDefaultRealmPath:storePath];

#endif

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"Eighth Edition"];
    DTSet *set = [[DTSet objectsWithPredicate:predicate] firstObject];
    _8thEditionReleaseDate = set.releaseDate;
    
#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
    [self loadInAppSets];
    
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
//    [MagicalRecord cleanUp];
}

-(void) copyRealmDatabaseToHome
{
    NSString *path = @"/Users/tontonsevilla/decktracker.realm";
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    [[RLMRealm defaultRealm] writeCopyToPath:path error:nil];
}

#pragma mark - Finders with FetchedResultsController
-(RLMResults*) findCards:(NSString*) query
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
        predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[c] %@", @"name", query];
    }
    else
    {
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@", @"name", query];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@", @"type", query];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@", @"text", query];
        NSPredicate *pred4 = [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@", @"flavor", query];
        predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred1, pred2, pred3, pred4]];
    }
    
    // to do: exclude In-App Sets
    NSArray *inAppSetCodes = [self inAppSetCodes];
    if (inAppSetCodes.count > 0)
    {
        NSPredicate *predInAppSets = [NSPredicate predicateWithFormat:@"NOT (set.code IN %@)", inAppSetCodes];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predInAppSets]];
    }
    
    return [[DTCard objectsWithPredicate:predicate] sortedResultsUsingDescriptors:sorters];
}

-(RLMResults*) findCards:(NSString*) query
           withPredicate:(NSPredicate*)predicate
     withSortDescriptors:(NSArray*) sorters
         withSectionName:(NSString*) sectionName
{
    NSPredicate *predicate2;
    
    if (query.length > 0)
    {
        if (query.length == 1)
        {
            NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[c] %@", @"name", query];
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
            NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@", @"name", query];
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
    
    NSPredicate *pred = predicate2 ? predicate2 : predicate;
    // to do: exclude In-App Sets
    NSArray *inAppSetCodes = [self inAppSetCodes];
    if (inAppSetCodes.count > 0)
    {
        NSPredicate *predInAppSets = [NSPredicate predicateWithFormat:@"NOT (set.code IN %@)", inAppSetCodes];
        pred = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred, predInAppSets]];
    }
    
    return [[DTCard objectsWithPredicate:pred] sortedResultsUsingDescriptors:sorters];
}

-(RLMResults*) advanceFindCards:(NSDictionary*)query
                     withSorter:(NSDictionary*) sorter
{
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSMutableArray *arrParams = [[NSMutableArray alloc] init];
    NSString *defaultFieldName;
    NSArray *defaultFieldValues;
    
    for (NSString *key in [query allKeys])
    {
        NSString *fieldName;
        BOOL bToMany = NO;
        
        if ([key isEqualToString:@"Name"])
        {
            fieldName = @"name";
        }
        else if ([key isEqualToString:@"Set"])
        {
            fieldName = @"set.name";
//            bToMany = YES;
        }
        else if ([key isEqualToString:@"Format"])
        {
            fieldName = @"legalities.format.name";
            defaultFieldName = @"legalities.name";
            defaultFieldValues = @[@"Legal", @"Restricted"];
            bToMany = YES;
        }
        else if ([key isEqualToString:@"Rarity"])
        {
            fieldName = @"rarity.name";
//            bToMany = YES;
        }
        else if ([key isEqualToString:@"Type"])
        {
            fieldName = @"types.name";
            bToMany = YES;
        }
        else if ([key isEqualToString:@"Subtype"])
        {
            fieldName = @"subTypes.name";
            bToMany = YES;
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
        }
        else if ([key isEqualToString:@"Will Be Reprinted?"])
        {
            fieldName = @"reserved";
        }
        
        NSArray *arrQuery = query[key];
        if (arrQuery.count > 1)
        {
            NSDictionary *dict = [arrQuery firstObject];
            NSString *condition = [[dict allKeys] firstObject];
            
            if (sql.length > 0)
            {
                [sql appendFormat:@" %@ (", condition];
            }
            else
            {
                [sql appendFormat:@"("];
            }
            
            for (NSDictionary *dict2 in arrQuery)
            {
                condition = [[dict2 allKeys] firstObject];
                id value = dict2[condition];
                
                if ([value isEqualToString:@"Yes"])
                {
                    value = [NSNumber numberWithBool:NO];
                }
                else if ([value isEqualToString:@"No"])
                {
                    value = [NSNumber numberWithBool:YES];
                }
                
                if ([arrQuery indexOfObject:dict2] != 0)
                {
                    [sql appendFormat:@" %@ ", condition];
                    
                }
                
                if (bToMany)
                {
                    [sql appendFormat:@"ANY %@ == %%@", fieldName];
                }
                else
                {
                    if ([value isKindOfClass:[NSNumber class]])
                    {
                        [sql appendFormat:@"ANY %@ CONTAINS[c] %%@", fieldName];
                    }
                    else
                    {
                        if (((NSString*)value).length == 1)
                        {
                            [sql appendFormat:@"%@ BEGINSWITH[c] %%@", fieldName];
                        }
                        else
                        {
                            [sql appendFormat:@"%@ CONTAINS[c] %%@", fieldName];
                        }
                    }
                }
                [arrParams addObject:value];
            }
            [sql appendString:@")"];
        }
        
        else
        {
            NSDictionary *dict = [arrQuery firstObject];
            NSString *condition = [[dict allKeys] firstObject];
            id value = dict[condition];
            
            if ([value isEqualToString:@"Yes"])
            {
                value = [NSNumber numberWithBool:NO];
            }
            else if ([value isEqualToString:@"No"])
            {
                value = [NSNumber numberWithBool:YES];
            }
            
            if (sql.length > 0)
            {
                [sql appendFormat:@" %@ ", condition];
            }
            
            if (bToMany)
            {
                [sql appendFormat:@"ANY %@ CONTAINS[c] %%@", fieldName];
            }
            else
            {
                if ([value isKindOfClass:[NSNumber class]])
                {
                    [sql appendFormat:@"%@ == %%@", fieldName];
                }
                else
                {
                    if (((NSString*)value).length == 1)
                    {
                        [sql appendFormat:@"%@ BEGINSWITH[c] %%@", fieldName];
                    }
                    else
                    {
                        [sql appendFormat:@"%@ CONTAINS[c] %%@", fieldName];
                    }
                }
                
            }
            [arrParams addObject:value];
        }
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:sql argumentArray:arrParams];
    if (defaultFieldName && defaultFieldValues)
    {
        NSPredicate *predDefault = [NSPredicate predicateWithFormat:@"ANY %K IN %@", defaultFieldName, defaultFieldValues];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predDefault]];
    }
    
    /*NSManagedObjectContext *moc = [NSManagedObjectContext MR_contextForCurrentThread];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"set.releaseDate"
                                                                    ascending:NO];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DTCard"
                                              inManagedObjectContext:moc];*/
    RLMSortDescriptor *sortDescriptor1 = [RLMSortDescriptor sortDescriptorWithProperty:@"name" ascending:YES];
//    RLMSortDescriptor *sortDescriptor2 = [RLMSortDescriptor sortDescriptorWithProperty:@"set.releaseDate" ascending:YES];
    
    
    // to do: exclude In-App Sets
    NSArray *inAppSetCodes = [self inAppSetCodes];
    if (inAppSetCodes.count > 0)
    {
        NSPredicate *predInAppSets = [NSPredicate predicateWithFormat:@"NOT (set.code IN %@)", inAppSetCodes];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predInAppSets]];
    }
    
    /*[fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
    [fetchRequest setFetchBatchSize:kFetchBatchSize];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:moc
                                                 sectionNameKeyPath:nil
                                                          cacheName:nil];*/
    
    return [[DTCard objectsWithPredicate:predicate] sortedResultsUsingDescriptors:@[sortDescriptor1/*, sortDescriptor2*/]];
}

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
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

-(NSDictionary*) inAppSettingsForSet:(NSString*) setId
{
    DTSet *set = [DTSet objectForPrimaryKey:setId];
    
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

-(BOOL) isSetPurchased:(DTSet*) set
{
    NSArray *inAppSetCodes = [self inAppSetCodes];
    
    if (inAppSetCodes.count > 0)
    {
        for (NSString *code in inAppSetCodes)
        {
            if ([set.code isEqualToString:code])
            {
                return NO;
            }
        }
    }
    
    return YES;
}
#endif

-(NSArray*) fetchRandomCards:(int) howMany
               withPredicate:(NSPredicate*) predicate
        includeInAppPurchase:(BOOL) inAppPurchase
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    RLMSortDescriptor *sortDescriptor1 = [RLMSortDescriptor sortDescriptorWithProperty:@"name" ascending:YES];
//    RLMSortDescriptor *sortDescriptor2 = [RLMSortDescriptor sortDescriptorWithProperty:@"set.releaseDate" ascending:NO];
    
    if (!inAppPurchase)
    {
        NSArray *inAppSetCodes = [self inAppSetCodes];
        if (inAppSetCodes.count > 0)
        {
            NSPredicate *predInAppSets = [NSPredicate predicateWithFormat:@"NOT (set.code IN %@)", inAppSetCodes];
            
            predicate = predicate ? [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predInAppSets]] : predInAppSets;
        }
    }
    
    // do not include cards without images
    NSPredicate *predWithoutImages = [NSPredicate predicateWithFormat:@"set.magicCardsInfoCode != %@", @""];
    predicate = predicate ? [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predWithoutImages]] : predWithoutImages;
    
    RLMResults *results = [[DTCard objectsWithPredicate:predicate] sortedResultsUsingDescriptors:@[sortDescriptor1/*, sortDescriptor2*/]];
    
    if (results.count > 0)
    {
        for (int i=0; i<howMany; i++)
        {
            int random = arc4random() % (results.count - 1) + 1;
            [array addObject:[results objectAtIndex:random+1]];
        }
    }
    
    return array;
}

#pragma mark - Finders
-(DTCard*) findCard:(NSString*) cardName inSet:(NSString*) setCode
{
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"name == %@", cardName];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"set.code == %@", setCode];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred1, pred2]];
    
    // to do: exclude In-App Sets
#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
    NSArray *inAppSetCodes = [self inAppSetCodes];
    if (inAppSetCodes.count > 0)
    {
        NSPredicate *predInAppSets = [NSPredicate predicateWithFormat:@"NOT (set.code IN %@)", inAppSetCodes];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predInAppSets]];
    }
#endif
    return [[DTCard objectsWithPredicate:predicate] firstObject];
}

-(DTCard*) findCardByMultiverseID:(NSString*) multiverseID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"multiverseID == %@", multiverseID];

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
    // to do: exclude In-App Sets
    NSArray *inAppSetCodes = [self inAppSetCodes];
    if (inAppSetCodes.count > 0)
    {
        NSPredicate *predInAppSets = [NSPredicate predicateWithFormat:@"NOT (set.code IN %@)", inAppSetCodes];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, predInAppSets]];
    }
#endif

    return [[DTCard objectsWithPredicate:predicate] firstObject];
}

-(void) fetchTcgPlayerPriceForCard:(NSString*) cardId
{
    __block DTCard *card = [DTCard objectForPrimaryKey:cardId];
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
    
    if (card.set.tcgPlayerName.length <= 0)
    {
        bWillFetch = NO;
    }
    
    if (bWillFetch)
    {
#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            card = [DTCard objectForPrimaryKey:cardId];
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
#ifdef DEBUG
            NSLog(@"^TCGPlayer: %@ [%@] - %@", card.set.name, card.set.code, card.name);
#endif
        
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];

            card.tcgPlayerHighPrice = high ? [high doubleValue] : card.tcgPlayerHighPrice;
            card.tcgPlayerMidPrice  = mid  ? [mid doubleValue]  : card.tcgPlayerMidPrice;
            card.tcgPlayerLowPrice  = low  ? [low doubleValue]  : card.tcgPlayerLowPrice;
            card.tcgPlayerFoilPrice = foil ? [foil doubleValue] : card.tcgPlayerFoilPrice;
            card.tcgPlayerLink = link ? [JJJUtil trim:link] : card.tcgPlayerLink;
            card.tcgPlayerFetchDate = [NSDate date];
            [realm commitWriteTransaction];
            
#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
            dispatch_async(dispatch_get_main_queue(), ^{
#endif
                [[NSNotificationCenter defaultCenter] postNotificationName:kPriceUpdateDone
                                                                    object:nil
                                                                  userInfo:@{@"cardId": cardId}];
#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
            });
        });
#endif
    }
}

-(NSArray*) fetchSets:(int) howMany
{
    RLMSortDescriptor *sortDescriptor1 = [RLMSortDescriptor sortDescriptorWithProperty:@"releaseDate"
                                                                             ascending:NO];
    RLMSortDescriptor *sortDescriptor2 = [RLMSortDescriptor  sortDescriptorWithProperty:@"name"
                                                                              ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"magicCardsInfoCode != %@", @""];

    NSMutableArray *arrResults = [[NSMutableArray alloc] init];
    RLMResults *sets = [[DTSet objectsWithPredicate:predicate] sortedResultsUsingDescriptors:@[sortDescriptor1, sortDescriptor2]];

    for (int i=0; i<howMany; i++)
    {
        DTSet *set = [sets objectAtIndex:i];
        [arrResults addObject:set.setId];
    }
    return arrResults;
}

-(BOOL) isCardModern:(NSString*) cardId
{
    DTCard *card = [DTCard objectForPrimaryKey:cardId];
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
        
        if (!error)
        {
            RLMRealm *realm = [RLMRealm defaultRealm];
            
            for (PFObject *object in objects)
            {
                NSPredicate *p = object[@"number"] ? [NSPredicate predicateWithFormat:@"(%K = %@ AND %K = %@ AND %K = %@)", @"name", object[@"name"], @"number", object[@"number"], @"set.name", object[@"set"][@"name"]] :
                [NSPredicate predicateWithFormat:@"%K = %@ AND %K = %@", @"name", object[@"name"], @"set.name", object[@"set"][@"name"]];
//                NSPredicate *p;
                
//                if (object[@"number"])
//                {
//                    p = [NSPredicate predicateWithFormat:@"(%K = %@ AND %K = %@ AND %K = %@)", @"name", object[@"name"], @"number", object[@"number"], @"set.name", object[@"set"][@"name"]];
//                }
//                else if (object[@"multiverseID"])
//                {
//                    p = [NSPredicate predicateWithFormat:@"(%K = %@ AND %K = %@ AND %K = %@)", @"name", object[@"name"], @"multiverseID", object[@"multiverseID"], @"set.name", object[@"set"][@"name"]];
//                }
//                else
//                {
//                    p = [NSPredicate predicateWithFormat:@"(%K = %@ AND %K = %@)", @"name", object[@"name"], @"set.name", object[@"set"][@"name"]];
//                }
                
                DTCard *card = [[DTCard objectsWithPredicate:p] firstObject];
                
                if (card)
                {
                    [realm beginWriteTransaction];
                    card.rating = [object[@"rating"] doubleValue];
                    [realm commitWriteTransaction];
                    [arrResults addObject:card.cardId];
                }
            }
        }
        else
        {
            RLMSortDescriptor *sortDescriptor1 = [RLMSortDescriptor sortDescriptorWithProperty:@"rating"
                                                                                     ascending:NO];
            RLMSortDescriptor *sortDescriptor2 = [RLMSortDescriptor sortDescriptorWithProperty:@"name"
                                                                                     ascending:YES];
            
            RLMResults *results = [[DTCard objectsWithPredicate:[NSPredicate predicateWithFormat:@"rating >= 0"]] sortedResultsUsingDescriptors:@[sortDescriptor1, sortDescriptor2]];
            for (int i=0; i<limit; i++)
            {
                DTCard *card = [results objectAtIndex:i];
                [arrResults addObject:card.cardId];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kFetchTopRatedDone
                                                            object:nil
                                                          userInfo:@{@"cardIds": arrResults}];
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
                NSPredicate *p = object[@"number"] ? [NSPredicate predicateWithFormat:@"(%K = %@ AND %K = %@ AND %K = %@)", @"name", object[@"name"], @"number", object[@"number"], @"set.name", object[@"set"][@"name"]] :
                [NSPredicate predicateWithFormat:@"%K = %@ AND %K = %@", @"name", object[@"name"], @"set.name", object[@"set"][@"name"]];
                
                DTCard *card = [[DTCard objectsWithPredicate:p] firstObject];
                if (card)
                {
                    [arrResults addObject:card.cardId];
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kFetchTopViewedDone
                                                            object:nil
                                                          userInfo:@{@"cardIds": arrResults}];
    }];
}

-(void) processCurrentParseQueue
{
    DTCard *card = _currentParseQueue[0];
    void (^callbackTask)(PFObject *pfCard) = _currentParseQueue[1];
    
    void (^callbackFindCard)(NSString *cardName, int multiverseID, NSString *cardNumber, PFObject *pfSet) = ^void(NSString *cardName, int multiverseID, NSString *cardNumber, PFObject *pfSet)
    {
        __block PFQuery *query = [PFQuery queryWithClassName:@"Card"];
        [query whereKey:@"name" equalTo:cardName];
        [query whereKey:@"multiverseID" equalTo:[NSNumber numberWithInt:multiverseID]];
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
                [query whereKey:@"multiverseID" equalTo:[NSNumber numberWithInt:multiverseID]];
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
                            pfCard[@"multiverseID"] = [NSNumber numberWithInt:multiverseID];
                            pfCard[@"set"] = pfSet;
                            pfCard[@"number"] = cardNumber;
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
    
    void (^callbackFindSet)(NSString *setName, NSString *setCode, NSString *cardName, int multiverseID, NSString *cardNumber) = ^void(NSString *setName, NSString *setCode, NSString *cardName, int multiverseID, NSString *cardNumber)
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
                 callbackFindCard(cardName, multiverseID, cardNumber, pfSet);
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
                               callbackFindCard(cardName, multiverseID, cardNumber, pfSet);
                          }];
                          return nil;
                      }];
                  }];
             }
             
             return task;
         }];
    };
    
    callbackFindSet(card.set.name, card.set.code, card.name, card.multiverseID, card.number);
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
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            card.rating = [pfCard[@"rating"] doubleValue];
            [realm commitWriteTransaction];
            
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
                double totalRating = 0;
                double averageRating = 0;
                
                for (PFObject *object in objects)
                {
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    [realm beginWriteTransaction];
                    DTCardRating *rating = [[DTCardRating alloc] init];
                    rating.rating = [object[@"rating"] floatValue];
                    rating.card = card;
                    [realm addObject:rating];
                    [realm commitWriteTransaction];
                    
                    totalRating += [object[@"rating"] doubleValue];
                }
                
                averageRating = totalRating/objects.count;
                if (isnan(averageRating))
                {
                    averageRating = 0;
                }
                
                pfCard[@"rating"] = [NSNumber numberWithDouble:averageRating];
                [pfCard saveEventually:^(BOOL success, NSError *error) {
                    
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    [realm beginWriteTransaction];
                    card.rating = averageRating;
                    [realm commitWriteTransaction];
                    
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

-(void) fetchUserMana
{
    PFUser *currentUser = [PFUser currentUser];
    
    if (!currentUser)
    {
        [self mergeLocalUserManaWithRemote:nil];
    }
    else
    {
        // find remotely first
        __block PFQuery *query = [PFQuery queryWithClassName:@"UserMana"];
        [query whereKey:@"user" equalTo:currentUser];
        
        [[query findObjectsInBackground] continueWithSuccessBlock:^id(BFTask *task)
        {
            return [[PFObject unpinAllObjectsInBackgroundWithName:@"UserMana"] continueWithSuccessBlock:^id(BFTask *ignored)
            {
                NSArray *results = task.result;
                         
                if (results.count > 0)
                {
                    // found remotely
                    PFObject *remoteUserMana = task.result[0];
                    [self mergeLocalUserManaWithRemote:remoteUserMana];
                }
                else
                {
                    // not found remotely
                    [self mergeLocalUserManaWithRemote:nil];
                }
                 
                return task;
             }];
        }];
    }
}

-(void) mergeLocalUserManaWithRemote:(PFObject*) remoteUserMana
{
    __block PFQuery *query = [PFQuery queryWithClassName:@"UserMana"];
    [query fromLocalDatastore];
    
    [[query findObjectsInBackground] continueWithBlock:^id(BFTask *task)
     {
         PFObject *localUserMana;
         
         if (task.error)
         {
             return task;
         }
         
         for (PFObject *object in task.result)
         {
             localUserMana = object;
         }
         
         if (localUserMana)
         {
             if (remoteUserMana)
             {
                 remoteUserMana[@"black"] = @([remoteUserMana[@"black"] integerValue] + [localUserMana[@"black"] integerValue]);
                 remoteUserMana[@"blue"] = @([remoteUserMana[@"blue"] integerValue] + [localUserMana[@"blue"] integerValue]);
                 remoteUserMana[@"green"] = @([remoteUserMana[@"green"] integerValue] + [localUserMana[@"green"] integerValue]);
                 remoteUserMana[@"red"] = @([remoteUserMana[@"red"] integerValue] + [localUserMana[@"red"] integerValue]);
                 remoteUserMana[@"white"] = @([remoteUserMana[@"white"] integerValue] + [localUserMana[@"white"] integerValue]);
                 remoteUserMana[@"colorless"] = @([remoteUserMana[@"colorless"] integerValue] + [localUserMana[@"colorless"] integerValue]);
                 remoteUserMana[@"totalCMC"] = @([remoteUserMana[@"black"] integerValue] +
                    [remoteUserMana[@"blue"] integerValue] +
                    [remoteUserMana[@"green"] integerValue] +
                    [remoteUserMana[@"red"] integerValue] +
                    [remoteUserMana[@"white"] integerValue] +
                    [remoteUserMana[@"colorless"] integerValue]);
                 [self saveUserMana:remoteUserMana];
             }
             else
             {
                 [self saveUserMana:localUserMana];
             }
         }
         else
         {
             if (remoteUserMana)
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:kParseUserManaDone
                                                                     object:nil
                                                                   userInfo:@{@"userMana": remoteUserMana}];
             }
             else
             {
                 // not found in local store, create new one
                 localUserMana = [PFObject objectWithClassName:@"UserMana"];
                 localUserMana[@"black"]     = @0;
                 localUserMana[@"blue"]      = @0;
                 localUserMana[@"green"]     = @0;
                 localUserMana[@"red"]       = @0;
                 localUserMana[@"white"]     = @0;
                 localUserMana[@"colorless"] = @0;
                 localUserMana[@"totalCMC"]  = @0;
                 
                 [localUserMana pinInBackgroundWithBlock:^void(BOOL succeeded, NSError *error) {
                     [[NSNotificationCenter defaultCenter] postNotificationName:kParseUserManaDone
                                                                         object:nil
                                                                       userInfo:@{@"userMana": localUserMana}];
                 }];
             }
             
         }
         
         return task;
     }];
}

-(void) saveUserMana:(PFObject*) userMana
{
    PFUser *currentUser = [PFUser currentUser];
    
    if (!currentUser)
    {
        [userMana pinInBackgroundWithBlock:^void(BOOL succeeded, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kParseUserManaDone
                                                                object:nil
                                                              userInfo:@{@"userMana": userMana}];
        }];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kParseUserManaDone
                                                            object:nil
                                                          userInfo:@{@"userMana": userMana}];
        
        if (userMana)
        {
            userMana[@"user"] = currentUser;
            [userMana saveEventually];
        }
        [self deleteUserManaLocally];
    }
}

-(void) deleteUserManaLocally
{
    __block PFQuery *query = [PFQuery queryWithClassName:@"UserMana"];
    [query fromLocalDatastore];
    
    [[query findObjectsInBackground] continueWithBlock:^id(BFTask *task)
    {
        PFObject *pfUserMana;
         
        if (task.error)
        {
            return task;
        }
         
        for (PFObject *object in task.result)
        {
            pfUserMana = object;
            [pfUserMana unpinInBackground];
        }
        return task;
     }];
}

-(void) fetchLeaderboard
{
    NSMutableArray *arrResults = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"UserMana"];
    query.limit = 15;
    
    [query includeKey:@"user"];
    [query orderByDescending:@"totalCMC"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            [arrResults addObjectsFromArray:objects];
        }
        else
        {
            NSLog(@"%@", error);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kParseLeaderboardDone
                                                            object:nil
                                                          userInfo:@{@"leaderboard": arrResults}];
    }];
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

-(void) updateParseSets
{
    PFQuery *query = [PFQuery queryWithClassName:@"Set"];
    [query whereKeyDoesNotExist:@"magicCardsInfoCode"];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            for (PFObject *pfSet in objects)
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@ AND code = %@", pfSet[@"name"], pfSet[@"code"]];
                
                DTSet *set = [[DTSet objectsWithPredicate:predicate] firstObject];
                
                if (set)
                {
                    pfSet[@"magicCardsInfoCode"] = set.magicCardsInfoCode;
                    [pfSet saveEventually:^(BOOL success, NSError *error) {
                        if (!error)
                        {
                            NSLog(@"Updated: %@ - %@: %@", set.name, set.code, set.magicCardsInfoCode);
                        }
                        else
                        {
                            NSLog(@"%@", error);
                        }
                    }];
                }
            }
        }
    }];
    
    
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"magicCardsInfoCode != %@", @""];
    //
    //    for (DTSet *set in [[DTSet objectsWithPredicate:predicate] sortedResultsUsingProperty:@"releaseDate" ascending:NO] )
    //    {
    //        PFQuery *query = [PFQuery queryWithClassName:@"Set"];
    //        [query whereKey:@"name" equalTo:set.name];
    //        [query whereKey:@"code" equalTo:set.code];
    //
    //        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    //
    //            if (!error)
    //            {
    //                for (PFObject *pfSet in objects)
    //                {
    //                    pfSet[@"magicCardsInfoCode"] = set.magicCardsInfoCode;
    //                    [pfSet saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    //                        if (!error)
    //                        {
    //                            NSLog(@"Updated: %@ - %@ = %@", set.name, set.code, set.magicCardsInfoCode);
    //                        }
    //                        else
    //                        {
    //                            NSLog(@"%@", error);
    //                        }
    //                    }];
    //                }
    //            }
    //        }];
    //    }
}


-(void) updateParseCards
{
    for (int i=0; i<6; i++)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Card"];
        [query whereKeyDoesNotExist:@"number"];
        [query includeKey:@"set"];
        [query orderByDescending:@"createdAt"];
        query.limit = 1000;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error)
            {
                for (PFObject *pfCard in objects)
                {
                    PFObject *pfSet = pfCard[@"set"];
                    if (!pfSet || !pfSet[@"magicCardsInfoCode"] || [pfSet[@"magicCardsInfoCode"] isEqualToString:@""])
                    {
                        continue;
                    }
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@ AND set.code = %@", pfCard[@"name"], pfSet[@"code"]];
                    
                    DTCard *card = [[DTCard objectsWithPredicate:predicate] firstObject];
                    if (card)
                    {
                        pfCard[@"number"] = card.number;
                        NSString *setName = card.set.name;
                        NSString *setCode = card.set.code;
                        NSString *cardName = card.name;
                        NSString *cardNumber = card.number;
                        
                        [pfCard saveEventually:^(BOOL success, NSError *error) {
                            if (!error)
                            {
                                NSLog(@"#%d Updated: %@ - %@: %@(%@)", i, setName, setCode, cardName, cardNumber);
                            }
                            else
                            {
                                NSLog(@"%@", error);
                            }
                        }];
                    }
                }
            }
        }];
    }
}

#endif

@end

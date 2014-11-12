//
//  Database.m
//  DeckTracker
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "Database.h"
#import "Magic.h"
#import "Set.h"

#import "TFHpple.h"

@implementation Database

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
        
    }
    
    return self;
}

-(void) setupDb
{
#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
    NSString *jsonVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"JSON Version"];
    NSString *imagesVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Images Version"];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *storePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", kDatabaseStore]];
    
    NSDictionary *arrCardUpdates = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Card Updates"];
    for (NSString *ver in [arrCardUpdates allKeys])
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
-(NSFetchedResultsController*) search:(NSString*)query
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
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                    ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"set.releaseDate"
                                                                    ascending:YES];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card"
                                              inManagedObjectContext:moc];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
    [fetchRequest setFetchBatchSize:kFetchBatchSize];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:moc
                                                 sectionNameKeyPath:nil
                                                          cacheName:nil];
}

-(NSFetchedResultsController*) search:(NSString*) query withPredicate:(NSPredicate*)predicate
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
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                    ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"set.releaseDate"
                                                                    ascending:YES];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card"
                                              inManagedObjectContext:moc];
    
    [fetchRequest setPredicate:predicate2 ? predicate2 : predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
    [fetchRequest setFetchBatchSize:kFetchBatchSize];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:moc
                                                 sectionNameKeyPath:nil
                                                          cacheName:nil];
}

-(NSFetchedResultsController*) advanceSearch:(NSDictionary*)query withSorter:(NSDictionary*) sorter
{
    NSPredicate *predicate;
    
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
        else if ([key isEqualToString:@"Rarity"])
        {
            fieldName = @"rarity.name";
//            bToMany = YES;
        }
        else if ([key isEqualToString:@"Type"])
        {
            fieldName = @"types.name";
//            bToMany = YES;
        }
        else if ([key isEqualToString:@"Subtype"])
        {
            fieldName = @"subTypes.name";
//            bToMany = YES;
        }
        else if ([key isEqualToString:@"Color"])
        {
            fieldName = @"colors.name";
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
        
        for (NSDictionary *dict in query[key])
        {
            NSPredicate *pred;
            NSString *condition = [[dict allKeys] firstObject];
            NSString *stringValue = [[dict allValues] firstObject];
            
            if ([key isEqualToString:@"Color"])
            {
                if ([stringValue isEqualToString:@"Colorless"])
                {
                    fieldName = @"colors";
                    stringValue = nil;
                }
                else
                {
                    fieldName = @"colors.name";
                }
            }
            
            if (stringValue)
            {
                if (bToMany)
                {
                    pred = [NSPredicate predicateWithFormat:@"ANY %K ==[cd] %@", fieldName, stringValue];
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
                                                                    ascending:YES];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card"
                                              inManagedObjectContext:moc];
    
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

-(Card*) findCard:(NSString*) cardName inSet:(NSString*) setCode
{
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"name == %@", cardName];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"set.code == %@", setCode];
    
    return [Card MR_findFirstWithPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[pred1, pred2]]];
}

-(NSString*) cardRarityIndex:(Card*) card
{
    return [card.rarity.name isEqualToString:@"Basic Land"] ? @"C" : [[card.rarity.name substringToIndex:1] uppercaseString];
}

-(Card*) fetchTcgPlayerPriceForCard:(Card*) card
{
    BOOL bWillFetch = NO;
    
    if (!card.tcgPlayerFetchDate)
    {
        bWillFetch = YES;
    }
    else
    {
        NSDate *today = [NSDate date];
        
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorian components:NSHourCalendarUnit
                                                    fromDate:card.tcgPlayerFetchDate
                                                      toDate:today
                                                     options:0];
        
        if ([components hour] >= TCGPLAYER_FETCH_STORAGE)
        {
            bWillFetch = YES;
        }
    }
    
    if (bWillFetch)
    {
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
        
        Card *c = [self findCard:card.name inSet:card.set.code];

        c.tcgPlayerHighPrice = high ? [NSNumber numberWithDouble:[high doubleValue]] : nil;
        c.tcgPlayerMidPrice  = mid  ? [NSNumber numberWithDouble:[mid doubleValue]]  : nil;
        c.tcgPlayerLowPrice  = low  ? [NSNumber numberWithDouble:[low doubleValue]]  : nil;
        c.tcgPlayerFoilPrice = foil ? [NSNumber numberWithDouble:[foil doubleValue]] : nil;
        c.tcgPlayerLink = [JJJUtil trim:link];
        c.tcgPlayerFetchDate = [NSDate date];
        
        NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
        [currentContext MR_save];
        return c;
    }
    
    else
    {
        return card;
    }
}

-(NSArray*) getRandomCards:(int) howMany
{
    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                    ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"set.releaseDate"
                                                                    ascending:YES];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card"
                                              inManagedObjectContext:moc];
    
    [fetchRequest setEntity:entity];
    NSUInteger count = [moc countForFetchRequest:fetchRequest error:NULL];
    NSMutableArray *arrIDs = [[NSMutableArray alloc] initWithCapacity:howMany];
    for (int i=0; i<howMany; i++)
    {
        [arrIDs addObject:[NSNumber numberWithInt:arc4random() %(count)]];
    }
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"cardID IN(%@)", arrIDs]];
    [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
    [fetchRequest setFetchLimit:howMany];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:fetchRequest error:&error];
    return array;
}

-(NSArray*) getSets:(int) howMany
{
    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"releaseDate"
                                                                    ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                    ascending:YES];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Set"
                                              inManagedObjectContext:moc];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
    [fetchRequest setFetchLimit:howMany];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:fetchRequest error:&error];
    return array;
}

@end

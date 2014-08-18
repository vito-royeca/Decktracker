//
//  Database.m
//  DeckTracker
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "Database.h"

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
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentPath = [paths lastObject];
    NSURL *storeURL = [documentPath URLByAppendingPathComponent:kDatabaseStore];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]])
    {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[kDatabaseStore stringByDeletingPathExtension] ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err])
        {
            NSLog(@"Error: Unable to copy preloaded database.");
        }
    }
#endif

    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kDatabaseStore];
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
//        if (narrow)
//        {
//            predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[cd] %@", @"name", query];
//        }
//        else
        {
            NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"name", query];
            NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"type", query];
            NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"text", query];
            NSPredicate *pred4 = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"flavor", query];
            predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred1, pred2, pred3, pred4]];
        }
    }
    
    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card"
                                              inManagedObjectContext:moc];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
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
        
        if ([key isEqualToString:@"Set"])
        {
            fieldName = @"set.name";
        }
        else if ([key isEqualToString:@"Rarity"])
        {
            fieldName = @"rarity.name";
        }
        else if ([key isEqualToString:@"Type"])
        {
            fieldName = @"types.name";
        }
        else if ([key isEqualToString:@"Subtype"])
        {
            fieldName = @"subTypes.name";
        }
//        else if ([key isEqualToString:@"Color"])
//        {
//            fieldName = @"manaCost";
//        }
        else if ([key isEqualToString:@"Artist"])
        {
            fieldName = @"artist.name";
        }
        
        for (NSDictionary *dict in [query objectForKey:key])
        {
            NSString *condition = [[dict allKeys] firstObject];
            NSString *stringValue;
            id value = [[dict allValues] firstObject];
            
            if ([value isKindOfClass:[NSManagedObject class]])
            {
                stringValue = [value performSelector:@selector(name) withObject:nil];
            }
            else if ([value isKindOfClass:[NSString class]])
            {
                stringValue = value;
            }
            
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", fieldName, stringValue];
            
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card"
                                              inManagedObjectContext:moc];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
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

@end

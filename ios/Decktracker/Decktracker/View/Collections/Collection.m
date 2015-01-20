//
//  Collection.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/17/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "Collection.h"
#import "Database.h"
#import "DTSet.h"
#import "FileManager.h"

@implementation Collection

@synthesize name = _name;
@synthesize notes = _notes;
@synthesize arrRegulars = _arrRegulars;
@synthesize arrFoils = _arrFoils;

-(id) initWithDictionary:(NSDictionary*) dict
{
    if (self = [super init])
    {
        NSSortDescriptor *sorter1 = [[NSSortDescriptor alloc] initWithKey:@"card.name"  ascending:YES];
        NSSortDescriptor *sorter2 = [[NSSortDescriptor alloc] initWithKey:@"card.set.releaseDate"  ascending:NO];
        NSArray *sorters = @[sorter1, sorter2];
        
        self.arrRegulars = [[NSMutableArray alloc] init];
        self.arrFoils = [[NSMutableArray alloc] init];
        int totalCards = 0;
        
        self.name = dict[@"name"];
        self.notes = dict[@"notes"];
        
        for (NSDictionary *d in dict[@"regular"])
        {
            DTCard *card;
            
            if (d[@"multiverseID"] && [d[@"multiverseID"] longValue] != 0)
            {
                card = [DTCard MR_findFirstByAttribute:@"multiverseID" withValue:d[@"multiverseID"]];
            }
            if (!card)
            {
                NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"name == %@", d[@"card"]];
                NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"set.code == %@", d[@"set"]];
                NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred1, pred2]];
                
                card = [DTCard MR_findFirstWithPredicate:predicate];
            }
            
            if (card)
            {
                [self.arrRegulars addObject:@{@"card" : card,
                                              @"set" : card.set.code,
                                              @"multiverseID" : card.multiverseID,
                                              @"qty" : d[@"qty"]}];
                totalCards += [d[@"qty"] intValue];
            }
        }
        
        for (NSDictionary *d in dict[@"foiled"])
        {
            DTCard *card;
            
            if (d[@"multiverseID"] && [d[@"multiverseID"] longValue] != 0)
            {
                card = [DTCard MR_findFirstByAttribute:@"multiverseID" withValue:d[@"multiverseID"]];
            }
            if (!card)
            {
                NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"name == %@", d[@"card"]];
                NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"set.code == %@", d[@"set"]];
                NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[pred1, pred2]];
                
                card = [DTCard MR_findFirstWithPredicate:predicate];
            }
            
            if (card)
            {
                [self.arrFoils addObject:@{@"card": card,
                                           @"set" : card.set.code,
                                           @"multiverseID" : card.multiverseID,
                                           @"qty" : d[@"qty"]}];
            }
        }
        
        self.arrRegulars = [[NSMutableArray alloc] initWithArray:[self.arrRegulars sortedArrayUsingDescriptors:sorters]];
        self.arrFoils = [[NSMutableArray alloc] initWithArray:[self.arrFoils sortedArrayUsingDescriptors:sorters]];
    }
    
    return self;
}

-(void) save:(NSString*) filePath
{
    NSMutableArray *arrRegulars = [[NSMutableArray alloc] init];
    NSMutableArray *arrFoils = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.arrRegulars)
    {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        DTCard *card = dict[@"card"];
        
        [newDict setValue:card.name forKey:@"card"];
        [arrRegulars addObject:newDict];
    }
    for (NSDictionary *dict in self.arrFoils)
    {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        DTCard *card = dict[@"card"];
        
        [newDict setValue:card.name forKey:@"card"];
        [arrFoils addObject:newDict];
    }
    
    NSDictionary *dict = @{@"name" : self.name,
                           @"notes" : self.notes ? self.notes : @"",
                           @"regular" : arrRegulars,
                           @"foiled" : arrFoils};
    
    [[FileManager sharedInstance] saveData:dict atPath:filePath];
}

-(void) updateCollection:(CollectionType) type withCard:(DTCard*) card withValue:(int) newValue
{
    NSMutableArray *arrType;
    NSDictionary *dictMain;
    
    switch (type)
    {
        case CollectionTypeRegular:
        {
            arrType = self.arrRegulars;
            break;
        }
            
        case CollectionTypeFoiled:
        {
            arrType = self.arrFoils;
            break;
        }
    }
    
    for (NSDictionary *dict in arrType)
    {
        DTCard *c = dict[@"card"];
        
        if (([dict[@"multiverseID"] longValue] != 0 && ([dict[@"multiverseID"] longValue] == [card.multiverseID longValue])) ||
            ([c.name isEqualToString:card.name] && [c.set.code isEqualToString:card.set.code]))
        {
            dictMain = dict;
            break;
        }
    }
    if (dictMain)
    {
        [arrType removeObject:dictMain];
        
        if (newValue > 0)
        {
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dictMain];
            
            [newDict setValue:[NSNumber numberWithInt:newValue] forKey:@"qty"];
            [newDict setValue:card.multiverseID forKey:@"multiverseID"];
            [arrType addObject:newDict];
        }
    }
    else
    {
        [arrType addObject:@{@"card" : card,
                             @"multiverseID" : card.multiverseID,
                             @"set"  : card.set.code,
                             @"qty"  : [NSNumber numberWithInt:newValue]}];
    }
}

-(int) cards:(DTCard*) card inType:(CollectionType) type
{
    NSMutableArray *arrType;
    int qty = 0;
    
    switch (type)
    {
        case CollectionTypeRegular:
        {
            arrType = self.arrRegulars;
            break;
        }
            
        case CollectionTypeFoiled:
        {
            arrType = self.arrFoils;
            break;
        }
    }
    
    for (NSDictionary *dict in arrType)
    {
        DTCard *c = dict[@"card"];
        
        if (([dict[@"multiverseID"] longValue] != 0 && ([dict[@"multiverseID"] longValue] == [card.multiverseID longValue])) ||
            ([c.name isEqualToString:card.name] && [c.set.code isEqualToString:card.set.code]))
        {
            qty = [dict[@"qty"] intValue];
            break;
        }
    }
    
    return qty;
}

@end

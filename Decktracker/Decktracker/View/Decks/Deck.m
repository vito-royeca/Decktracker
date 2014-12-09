//
//  Deck.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/17/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "Deck.h"
#import "Database.h"
#import "FileManager.h"

@implementation Deck
{
    NSMutableDictionary *_dict;
}

@synthesize name = _name;
@synthesize format = _format;
@synthesize notes = _notes;
@synthesize originalDesigner = _originalDesigner;
@synthesize year = _year;
@synthesize arrLands = _arrLands;
@synthesize arrCreatures = _arrCreatures;
@synthesize arrOtherSpells = _arrOtherSpells;
@synthesize arrSideboard = _arrSideboard;

-(id) initWithDictionary:(NSDictionary*) dict
{
    if (self = [super init])
    {
        NSSortDescriptor *sorter1 = [[NSSortDescriptor alloc] initWithKey:@"card.name"  ascending:YES];
        NSSortDescriptor *sorter2 = [[NSSortDescriptor alloc] initWithKey:@"card.set.releaseDate"  ascending:YES];
        NSArray *sorters = @[sorter1, sorter2];
        
        self.arrLands = [[NSMutableArray alloc] init];
        self.arrCreatures = [[NSMutableArray alloc] init];
        self.arrOtherSpells = [[NSMutableArray alloc] init];
        self.arrSideboard = [[NSMutableArray alloc] init];
        int totalCards = 0;
        
        self.name = dict[@"name"];
        self.format = dict[@"format"];
        self.notes = dict[@"notes"];
        self.originalDesigner = dict[@"originalDesigner"];
        self.year = dict[@"year"];
        
        for (NSDictionary *d in dict[@"mainBoard"])
        {
            DTCard *card;
            
            if (d[@"multiverseID"])
            {
                card = [DTCard MR_findFirstByAttribute:@"multiverseID" withValue:d[@"multiverseID"]];
            }
            if (!card)
            {
                card = [[Database sharedInstance] findCard:d[@"card"] inSet:d[@"set"]];
            }
            
            if ([JJJUtil string:card.type containsString:@"land"])
            {
                [self.arrLands addObject:@{@"card" : card,
                                           @"set" : card.set.code,
                                           @"multiverseID" : card.multiverseID,
                                           @"qty" : d[@"qty"]}];
                totalCards += [d[@"qty"] intValue];
            }
            else if ([JJJUtil string:card.type containsString:@"creature"])
            {
                [self.arrCreatures addObject:@{@"card": card,
                                               @"set" : card.set.code,
                                               @"multiverseID" : card.multiverseID,
                                               @"qty" : d[@"qty"]}];
                totalCards += [d[@"qty"] intValue];
            }
            else
            {
                [self.arrOtherSpells addObject:@{@"card": card,
                                                 @"set" : card.set.code,
                                                 @"multiverseID" : card.multiverseID,
                                                 @"qty" : d[@"qty"]}];
                totalCards += [d[@"qty"] intValue];
            }
        }
        
        for (NSDictionary *d in dict[@"sideBoard"])
        {
            DTCard *card;
            
            if (d[@"multiverseID"])
            {
                card = [DTCard MR_findFirstByAttribute:@"multiverseID" withValue:d[@"multiverseID"]];
            }
            if (!card)
            {
                card = [[Database sharedInstance] findCard:d[@"card"] inSet:d[@"set"]];
            }
            
            [self.arrSideboard addObject:@{@"card": card,
                                           @"set" : card.set.code,
                                           @"multiverseID" : card.multiverseID,
                                           @"qty" : d[@"qty"]}];
        }
        
        self.arrLands = [[NSMutableArray alloc] initWithArray:[self.arrLands sortedArrayUsingDescriptors:sorters]];
        self.arrCreatures = [[NSMutableArray alloc] initWithArray:[self.arrCreatures sortedArrayUsingDescriptors:sorters]];
        self.arrOtherSpells = [[NSMutableArray alloc] initWithArray:[self.arrOtherSpells sortedArrayUsingDescriptors:sorters]];
        self.arrSideboard = [[NSMutableArray alloc] initWithArray:[self.arrSideboard sortedArrayUsingDescriptors:sorters]];
    }

    return self;
}

-(void) save:(NSString*) filePath
{
    NSMutableArray *arrMainBoard = [[NSMutableArray alloc] init];
    NSMutableArray *arrSideBoard = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.arrLands)
    {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        DTCard *card = dict[@"card"];
        
        [newDict setValue:card.name forKey:@"card"];
        [arrMainBoard addObject:newDict];
    }
    for (NSDictionary *dict in self.arrCreatures)
    {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        DTCard *card = dict[@"card"];
        
        [newDict setValue:card.name forKey:@"card"];
        [arrMainBoard addObject:newDict];
    }
    for (NSDictionary *dict in self.arrOtherSpells)
    {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        DTCard *card = dict[@"card"];
        
        [newDict setValue:card.name forKey:@"card"];
        [arrMainBoard addObject:newDict];
    }
    for (NSDictionary *dict in self.arrSideboard)
    {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        DTCard *card = dict[@"card"];
        
        [newDict setValue:card.name forKey:@"card"];
        [arrSideBoard addObject:newDict];
    }
    
    NSDictionary *dict = @{@"name" : self.name,
                           @"format" : self.format ? self.format : @"",
                           @"notes" : self.notes ? self.notes : @"",
                           @"originalDesigner" : self.originalDesigner ? self.originalDesigner : @"",
                           @"year" : self.year ? self.year : @0,
                           @"mainBoard" : arrMainBoard,
                           @"sideBoard" : arrSideBoard};
    
    [[FileManager sharedInstance] saveData:dict atPath:filePath];
}

-(void) updateDeck:(DeckBoard) board withCard:(DTCard*) card withValue:(int) newValue
{
    NSMutableArray *arrBoard;
    NSDictionary *dictMain;
    
    switch (board)
    {
        case MainBoard:
        {
            if ([JJJUtil string:card.type containsString:@"land"])
            {
                arrBoard = self.arrLands;
            }
            else if ([JJJUtil string:card.type containsString:@"creature"])
            {
                arrBoard = self.arrCreatures;
            }
            else
            {
                arrBoard = self.arrOtherSpells;
            }
            break;
        }
            
        case SideBoard:
        {
            arrBoard = self.arrSideboard;
            break;
        }
    }

    for (NSDictionary *dict in arrBoard)
    {
        DTCard *c = dict[@"card"];
        
        if ([dict[@"multiverseID"] intValue] == [card.multiverseID intValue] ||
            ([c.name isEqualToString:card.name] && [c.set.code isEqualToString:card.set.code]))
        {
            dictMain = dict;
            break;
        }
    }
    if (dictMain)
    {
        [arrBoard removeObject:dictMain];
        
        if (newValue > 0)
        {
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dictMain];
            
            [newDict setValue:[NSNumber numberWithInt:newValue] forKey:@"qty"];
            [newDict setValue:card.multiverseID forKey:@"multiverseID"];
            [arrBoard addObject:newDict];
        }
    }
    else
    {
        [arrBoard addObject:@{@"card" : card,
                              @"multiverseID" : card.multiverseID,
                              @"set"  : card.set.code,
                              @"qty"  : [NSNumber numberWithInt:newValue]}];
    }
}

-(int) cards:(DTCard*) card inBoard:(DeckBoard) deckboard
{
    NSMutableArray *arrBoard;
    int qty = 0;
    
    switch (deckboard)
    {
        case MainBoard:
        {
            if ([JJJUtil string:card.type containsString:@"land"])
            {
                arrBoard = self.arrLands;
            }
            else if ([JJJUtil string:card.type containsString:@"creature"])
            {
                arrBoard = self.arrCreatures;
            }
            else
            {
                arrBoard = self.arrOtherSpells;
            }
            break;
        }
        case SideBoard:
        {
            arrBoard = self.arrSideboard;
            break;
        }
    }
    
    for (NSDictionary *dict in arrBoard)
    {
        DTCard *c = dict[@"card"];
        
        if ([dict[@"multiverseID"] intValue] == [card.multiverseID intValue] ||
            ([c.name isEqualToString:card.name] && [c.set.code isEqualToString:card.set.code]))
        {
            qty = [dict[@"qty"] intValue];
            break;
        }
    }
    
    return qty;
}

-(int) cardsInBoard:(DeckBoard) deckboard;
{
    NSMutableArray *arrBoard;
    int qty = 0;
    
    switch (deckboard)
    {
        case MainBoard:
        {
            arrBoard = [[NSMutableArray alloc] initWithArray:self.arrLands];
            [arrBoard addObjectsFromArray:self.arrCreatures];
            [arrBoard addObjectsFromArray:self.arrOtherSpells];
            break;
        }
        case SideBoard:
        {
            arrBoard = self.arrSideboard;
            break;
        }
    }
    
    for (NSDictionary *dict in arrBoard)
    {
        qty += [dict[@"qty"] intValue];
    }
    
    return qty;
}

@end

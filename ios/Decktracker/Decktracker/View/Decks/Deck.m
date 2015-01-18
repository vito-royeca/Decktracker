//
//  Deck.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/17/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "Deck.h"
#import "Database.h"
#import "DTCardColor.h"
#import "FileManager.h"
#import "Magic.h"

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
//        NSManagedObjectContext *privateContext = [NSManagedObjectContext MR_context];
//        [privateContext performBlock:^{
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                
//            });
//        }];
        
        NSSortDescriptor *sorter1 = [[NSSortDescriptor alloc] initWithKey:@"card.name"  ascending:YES];
        NSSortDescriptor *sorter2 = [[NSSortDescriptor alloc] initWithKey:@"card.set.releaseDate"  ascending:NO];
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
            NSDictionary *pack;
            
            if (d[@"multiverseID"] && [d[@"multiverseID"] longValue] != 0)
            {
                card = [DTCard MR_findFirstByAttribute:@"multiverseID" withValue:d[@"multiverseID"]];
            }
            if (!card)
            {
                card = [[Database sharedInstance] findCard:d[@"card"] inSet:d[@"set"]];
            }
            
            pack = @{@"card" : card,
                     @"set" : card.set ? card.set.code : @"",
                     @"multiverseID" : card.multiverseID,
                     @"qty" : d[@"qty"]};
            
            if ([card.type containsString:@"Land"] || [card.type hasPrefix:@"Land"])
            {
                [self.arrLands addObject:pack];
                totalCards += [d[@"qty"] intValue];
            }
            else if ([card.type containsString:@"Creature"] || [card.type hasPrefix:@"Creature"] ||
                     [card.type containsString:@"Summon"] || [card.type hasPrefix:@"Summon"])
            {
                [self.arrCreatures addObject:pack];
                totalCards += [d[@"qty"] intValue];
            }
            else
            {
                [self.arrOtherSpells addObject:pack];
                totalCards += [d[@"qty"] intValue];
            }
        }
        
        for (NSDictionary *d in dict[@"sideBoard"])
        {
            DTCard *card;
            NSDictionary *pack;
            
            if (d[@"multiverseID"] && [d[@"multiverseID"] longValue] != 0)
            {
                card = [DTCard MR_findFirstByAttribute:@"multiverseID" withValue:d[@"multiverseID"]];
            }
            if (!card)
            {
                card = [[Database sharedInstance] findCard:d[@"card"] inSet:d[@"set"]];
            }
            
            pack = @{@"card" : card,
                     @"set" : card.set ? card.set.code : @"",
                     @"multiverseID" : card.multiverseID,
                     @"qty" : d[@"qty"]};
            
            [self.arrSideboard addObject:pack];
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
            if ([card.type containsString:@"Land"] || [card.type hasPrefix:@"Land"])
                
            {
                arrBoard = self.arrLands;
            }
            else if ([card.type containsString:@"Creature"] || [card.type hasPrefix:@"Creature"] ||
                     [card.type containsString:@"Summon"] || [card.type hasPrefix:@"Summon"])
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
        
        if (([dict[@"multiverseID"] longValue] != 0 && ([dict[@"multiverseID"] longValue] == [card.multiverseID longValue])) ||
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
            if ([card.type containsString:@"Land"] || [card.type hasPrefix:@"Land"])
            {
                arrBoard = self.arrLands;
            }
            else if ([card.type containsString:@"Creature"] || [card.type hasPrefix:@"Creature"] ||
                     [card.type containsString:@"Summon"] || [card.type hasPrefix:@"Summon"])
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
        
        if (([dict[@"multiverseID"] longValue] != 0 && ([dict[@"multiverseID"] longValue] == [card.multiverseID longValue])) ||
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

-(void) deletePieImage
{
    NSString *path = [NSString stringWithFormat:@"%@/%@.png", [[FileManager sharedInstance] tempPath], self.name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

-(NSString*) averagePrice
{
    NSNumberFormatter *formatter =  [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    double totalPrice = 0;
    
    for (NSDictionary *dict in self.arrLands)
    {
        DTCard *card = dict[@"card"];
        NSNumber *qty = dict[@"qty"];
        
        if (card.tcgPlayerMidPrice)
        {
            totalPrice += ([card.tcgPlayerMidPrice doubleValue] * [qty intValue]);
        }
    }
    
    for (NSDictionary *dict in self.arrCreatures)
    {
        DTCard *card = dict[@"card"];
        NSNumber *qty = dict[@"qty"];
        
        if (card.tcgPlayerMidPrice)
        {
            totalPrice += ([card.tcgPlayerMidPrice doubleValue] * [qty intValue]);
        }
    }
    
    for (NSDictionary *dict in self.arrOtherSpells)
    {
        DTCard *card = dict[@"card"];
        NSNumber *qty = dict[@"qty"];
        
        if (card.tcgPlayerMidPrice)
        {
            totalPrice += ([card.tcgPlayerMidPrice doubleValue] * [qty intValue]);
        }
    }
    
    for (NSDictionary *dict in self.arrSideboard)
    {
        DTCard *card = dict[@"card"];
        NSNumber *qty = dict[@"qty"];
        
        if (card.tcgPlayerMidPrice)
        {
            totalPrice += ([card.tcgPlayerMidPrice doubleValue] * [qty intValue]);
        }
    }
    
    return [NSString stringWithFormat:@"%@", [formatter stringFromNumber:[NSNumber numberWithDouble:totalPrice]]];
}

-(NSArray*) cardTypeDistribution:(BOOL) detailed
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int total = 0;
    
    if (self.arrLands.count > 0)
    {
        for (NSDictionary *dict in self.arrLands)
        {
            total += [dict[@"qty"] intValue];
        }
        [array addObject:@{@"Lands": [NSNumber numberWithInt:total]}];
    }
    
    if (self.arrCreatures.count > 0)
    {
        total = 0;
        for (NSDictionary *dict in self.arrCreatures)
        {
            total += [dict[@"qty"] intValue];
        }
        [array addObject:@{@"Creatures": [NSNumber numberWithInt:total]}];
    }

    if (detailed)
    {
        for (NSDictionary *dict in self.arrOtherSpells)
        {
            DTCard *card = dict[@"card"];
            int qty = [dict[@"qty"] intValue];
            
            for (NSString *type in CARD_TYPES)
            {
                if ([card.type containsString:type] || [card.type hasPrefix:type])
                {
                    NSDictionary *object;
                    
                    for (NSDictionary *dict in array)
                    {
                        if ([[dict allKeys][0] isEqualToString:type])
                        {
                            object = dict;
                            break;
                        }
                    }
                    
                    if (object)
                    {
                        int num = [object[type] intValue];
                        
                        NSMutableDictionary *mut = (NSMutableDictionary*) object;
                        [mut setObject:[NSNumber numberWithInt:num+qty] forKey:type];
                    }
                    else
                    {
                        NSMutableDictionary *mut = [[NSMutableDictionary alloc] init];
                        [mut setObject:[NSNumber numberWithInt:qty] forKey:type];
                        [array addObject:mut];
                    }
                }
            }
        }
    }
    else
    {
        total = 0;
        for (NSDictionary *dict in self.arrOtherSpells)
        {
            total += [dict[@"qty"] intValue];
        }
        [array addObject:@{@"Other Spells": [NSNumber numberWithInt:total]}];
    }
    
    return array;
}

-(NSArray*) colorDistribution:(BOOL) detailed
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *combinedArray = [NSMutableArray arrayWithArray:self.arrCreatures];
    
    [combinedArray addObjectsFromArray:self.arrOtherSpells];
    
    for (NSDictionary *dict in combinedArray)
    {
        DTCard *card = dict[@"card"];
        int qty = [dict[@"qty"] intValue];
        
        if (card.colors.count > 0)
        {
            for (DTCardColor *color in card.colors)
            {
                NSDictionary *object;
                
                for (NSDictionary *dict in array)
                {
                    if ([[dict allKeys][0] isEqualToString:color.name])
                    {
                        object = dict;
                        break;
                    }
                }
                
                if (object)
                {
                    int num = [object[color.name] intValue];
                    
                    NSMutableDictionary *mut = (NSMutableDictionary*) object;
                    [mut setObject:[NSNumber numberWithInt:num+qty] forKey:color.name];
                }
                else
                {
                    NSMutableDictionary *mut = [[NSMutableDictionary alloc] init];
                    [mut setObject:[NSNumber numberWithInt:qty] forKey:color.name];
                    [array addObject:mut];
                }
            }
        }
        else
        {
            if (detailed)
            {
                NSDictionary *object;
                NSString *colorless = @"Colorless";
                
                for (NSDictionary *dict in array)
                {
                    if ([[dict allKeys][0] isEqualToString:colorless])
                    {
                        object = dict;
                        break;
                    }
                }
                
                if (object)
                {
                    int num = [object[colorless] intValue];
                    
                    NSMutableDictionary *mut = (NSMutableDictionary*) object;
                    [mut setObject:[NSNumber numberWithInt:num+qty] forKey:colorless];
                }
                else
                {
                    NSMutableDictionary *mut = [[NSMutableDictionary alloc] init];
                    [mut setObject:[NSNumber numberWithInt:qty] forKey:colorless];
                    [array addObject:mut];
                }
            }
        }
    }
    
    return array;
}

-(NSArray*) manaSourceDistribution:(BOOL) detailed
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in self.arrLands)
    {
        DTCard *card = dict[@"card"];
        int qty = [dict[@"qty"] intValue];
        
        if (card.colors.count > 0)
        {
            for (DTCardColor *color in card.colors)
            {
                NSDictionary *object;
                
                for (NSDictionary *dict in array)
                {
                    if ([[dict allKeys][0] isEqualToString:color.name])
                    {
                        object = dict;
                        break;
                    }
                }
                
                if (object)
                {
                    int num = [object[color.name] intValue];
                    
                    NSMutableDictionary *mut = (NSMutableDictionary*) object;
                    [mut setObject:[NSNumber numberWithInt:num+qty] forKey:color.name];
                }
                else
                {
                    NSMutableDictionary *mut = [[NSMutableDictionary alloc] init];
                    [mut setObject:[NSNumber numberWithInt:qty] forKey:color.name];
                    [array addObject:mut];
                }
            }
        }
        else
        {
            if (detailed)
            {
                NSDictionary *object;
                NSString *colorless = @"Colorless";
                
                for (NSDictionary *dict in array)
                {
                    if ([[dict allKeys][0] isEqualToString:colorless])
                    {
                        object = dict;
                        break;
                    }
                }
                
                if (object)
                {
                    int num = [object[colorless] intValue];
                    
                    NSMutableDictionary *mut = (NSMutableDictionary*) object;
                    [mut setObject:[NSNumber numberWithInt:num+qty] forKey:colorless];
                }
                else
                {
                    NSMutableDictionary *mut = [[NSMutableDictionary alloc] init];
                    [mut setObject:[NSNumber numberWithInt:qty] forKey:colorless];
                    [array addObject:mut];
                }
            }
        }
    }
    
    return array;
}

-(NSArray*) cardColors:(BOOL) detailed
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *combinedArray = [NSMutableArray arrayWithArray:self.arrCreatures];
    
    [combinedArray addObjectsFromArray:self.arrOtherSpells];
    
    for (NSDictionary *dict in combinedArray)
    {
        DTCard *card = dict[@"card"];
        
        if (card.colors.count > 0)
        {
            for (DTCardColor *color in card.colors)
            {
                BOOL hasColor = NO;
                
                for (NSString *colorName in array)
                {
                    if ([colorName isEqualToString:color.name])
                    {
                        hasColor = YES;
                        break;
                    }
                }
                
                if (!hasColor)
                {
                    [array addObject:color.name];
                }
            }
        }
        else
        {
            if (detailed)
            {
                BOOL hasColor = NO;
                NSString *colorless = @"Colorless";
                
                for (NSString *colorName in array)
                {
                    if ([colorName isEqualToString:colorless])
                    {
                        hasColor = YES;
                        break;
                    }
                }
                
                if (!hasColor)
                {
                    [array addObject:colorless];
                }
            }
        }
    }
    
    return array;
}

-(NSArray*) manaSourceColors:(BOOL) detailed
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in self.arrLands)
    {
        DTCard *card = dict[@"card"];
        
        if (card.colors.count > 0)
        {
            for (DTCardColor *color in card.colors)
            {
                BOOL hasColor = NO;
                
                for (NSString *colorName in array)
                {
                    if ([colorName isEqualToString:color.name])
                    {
                        hasColor = YES;
                        break;
                    }
                }
                
                if (!hasColor)
                {
                    [array addObject:color.name];
                }
            }
        }
        else
        {
            if (detailed)
            {
                BOOL hasColor = NO;
                NSString *colorless = @"Colorless";
                
                for (NSString *colorName in array)
                {
                    if ([colorName isEqualToString:colorless])
                    {
                        hasColor = YES;
                        break;
                    }
                }
                
                if (!hasColor)
                {
                    [array addObject:colorless];
                }
            }
        }
    }
    
    return array;
}


@end

//
//  DeckIASKSettingsStore.m
//  Decktracker
//
//  Created by Jovit Royeca on 11/10/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "DeckIASKSettingsStore.h"

#import "FileManager.h"

@implementation DeckIASKSettingsStore

@synthesize deck = _deck;

- (void)setObject:(id)value forKey:(NSString*)key
{
    if ([key isEqualToString:@"name"])
    {
        self.deck.name = value;
    }
    else if ([key isEqualToString:@"format"])
    {
        self.deck.format = value;
    }
    else if ([key isEqualToString:@"notes"])
    {
        self.deck.notes = value;
    }
    else if ([key isEqualToString:@"originalDesigner"])
    {
        self.deck.originalDesigner = value;
    }
    else if ([key isEqualToString:@"year"])
    {
        self.deck.year = value;
    }
}

- (id)objectForKey:(NSString*)key
{
    if ([key isEqualToString:@"name"])
    {
        return self.deck.name;
    }
    else if ([key isEqualToString:@"numberOfCards"])
    {
        return [NSString stringWithFormat:@"Mainboard: %d / Sideboard: %d", [self.deck cardsInBoard:MainBoard], [self.deck cardsInBoard:SideBoard]];
    }
    else if ([key isEqualToString:@"averagePrice"])
    {
        return [self.deck averagePrice];
    }
    else if ([key isEqualToString:@"format"])
    {
        return self.deck.format;
    }
    else if ([key isEqualToString:@"notes"])
    {
        return self.deck.notes;
    }
    else if ([key isEqualToString:@"originalDesigner"])
    {
        return self.deck.originalDesigner;
    }
    else if ([key isEqualToString:@"year"])
    {
        return self.deck.year;
    }
    else
    {
        return nil;
    }
}

- (BOOL)synchronize
{
    NSString *path = [NSString stringWithFormat:@"/Decks/%@.json", self.deck.name];
    [[FileManager sharedInstance] deleteFileAtPath:path];
    
    path = [NSString stringWithFormat:@"/Decks/%@.json", self.deck.name];
    [self.deck save:path];
    
    return YES;
}

@end

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
        NSNumberFormatter *formatter =  [[NSNumberFormatter alloc] init];
//        [formatter setUsesSignificantDigits:YES];
        [formatter setMaximumFractionDigits:2];
        [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        double totalPrice = 0;
        
        for (NSDictionary *dict in self.deck.arrLands)
        {
            DTCard *card = dict[@"card"];
            NSNumber *qty = dict[@"qty"];
            
            if (card.tcgPlayerMidPrice)
            {
                totalPrice += ([card.tcgPlayerMidPrice doubleValue] * [qty intValue]);
            }
        }
        
        for (NSDictionary *dict in self.deck.arrCreatures)
        {
            DTCard *card = dict[@"card"];
            NSNumber *qty = dict[@"qty"];
            
            if (card.tcgPlayerMidPrice)
            {
                totalPrice += ([card.tcgPlayerMidPrice doubleValue] * [qty intValue]);
            }
        }
        
        for (NSDictionary *dict in self.deck.arrOtherSpells)
        {
            DTCard *card = dict[@"card"];
            NSNumber *qty = dict[@"qty"];
            
            if (card.tcgPlayerMidPrice)
            {
                totalPrice += ([card.tcgPlayerMidPrice doubleValue] * [qty intValue]);
            }
        }
        
        for (NSDictionary *dict in self.deck.arrSideboard)
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

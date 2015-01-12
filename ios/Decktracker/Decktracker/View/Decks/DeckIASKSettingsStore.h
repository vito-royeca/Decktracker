//
//  DeckIASKSettingsStore.h
//  Decktracker
//
//  Created by Jovit Royeca on 11/10/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Deck.h"

#import "IASKSettingsStore.h"

@interface DeckIASKSettingsStore : IASKAbstractSettingsStore

@property(strong,nonatomic) Deck *deck;

@end

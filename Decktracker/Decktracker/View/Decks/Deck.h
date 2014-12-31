//
//  Deck.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/17/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import Foundation;

#import "DTCard.h"
#import "JJJ/JJJ.h"

typedef NS_ENUM(NSInteger, DeckBoard)
{
    MainBoard,
    SideBoard
};

@interface Deck : NSObject

@property(strong,nonatomic) NSString *name;
@property(strong,nonatomic) NSString *format;
@property(strong,nonatomic) NSString *notes;
@property(strong,nonatomic) NSString *originalDesigner;
@property(strong,nonatomic) NSNumber *year;
@property(strong,nonatomic) NSMutableArray *arrLands;
@property(strong,nonatomic) NSMutableArray *arrCreatures;
@property(strong,nonatomic) NSMutableArray *arrOtherSpells;
@property(strong,nonatomic) NSMutableArray *arrSideboard;

-(id) initWithDictionary:(NSDictionary*) dict;
-(void) save:(NSString*) filePath;
-(void) updateDeck:(DeckBoard) board withCard:(DTCard*) card withValue:(int) newValue;
-(int) cards:(DTCard*) card inBoard:(DeckBoard) deckboard;
-(int) cardsInBoard:(DeckBoard) deckboard;

-(NSArray*) cardTypeDistribution:(BOOL) detailed;

-(NSArray*) colorDistribution:(BOOL) detailed;
-(NSArray*) cardColors:(BOOL) detailed;

-(NSArray*) manaSourceDistribution:(BOOL) detailed;
-(NSArray*) manaSourceColors:(BOOL) detailed;

@end

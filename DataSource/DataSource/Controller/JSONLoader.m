//
//  JSONLoader.m
//  DataSource
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "JSONLoader.h"
#import "JJJ/JJJUtil.h"
#import "Artist.h"
#import "Block.h"
#import "Card.h"
#import "CardForeignName.h"
#import "CardLegality.h"
#import "CardRarity.h"
#import "CardRuling.h"
#import "CardType.h"
#import "Database.h"
#import "Format.h"
#import "Magic.h"
#import "Set.h"
#import "SetType.h"

@implementation JSONLoader

-(void) parseJSON
{
    NSDate *dateStart = [NSDate date];
    [[Database sharedInstance] setupDb];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Data/AllSets-x.json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    for (NSString *setName in [json allKeys])
    {
        NSDictionary * dict = [json objectForKey:setName];
        [self parseSet:dict];
        [currentContext MR_save];
    }
    
    for (NSString *setName in [json allKeys])
    {
        NSDictionary * dict = [json objectForKey:setName];
        Set *set = [self parseSet:dict];
        NSSet *cards = [self parseCards:[dict objectForKey:@"cards"] forSet:set];
        set.numberOfCards = [NSNumber numberWithInt:(int)cards.count];
        [currentContext MR_save];
    }
    
    for (NSString *setName in [json allKeys])
    {
        NSDictionary * dict = [json objectForKey:setName];
        
        for (NSDictionary *dictNames in [dict objectForKey:@"cards"])
        {
            NSString *cardName = [dictNames objectForKey:@"name"];
            NSArray *names = [dictNames objectForKey:@"names"];
            NSArray *variations = [dictNames objectForKey:@"variations"];
            
            [self setNames:names andVariations:variations forCard:cardName];
        }
    }
    
    [[Database sharedInstance] closeDb];
    
    NSDate *dateEnd = [NSDate date];
    NSTimeInterval timeDifference = [dateEnd timeIntervalSinceDate:dateStart];
    NSLog(@"Started: %@", dateStart);
    NSLog(@"Ended: %@", dateEnd);
    NSLog(@"Time Elapsed: %@",  [JJJUtil formatInterval:timeDifference]);
}

-(void) insertSymbols
{
    
    
}

#pragma mark - Sets parsing
-(Set*) parseSet:(NSDictionary*) dict
{
    if (!dict || dict.count == 0)
    {
        return nil;
    }
    
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    Set *set = [Set MR_findFirstByAttribute:@"name"
                                  withValue:[dict objectForKey:@"name"]];
    
    if (!set)
    {
        set = [Set MR_createEntity];
        
        set.name = [dict objectForKey:@"name"];
        set.code = [dict objectForKey:@"code"];
        set.gathererCode = [dict objectForKey:@"gathererCode"];
        set.oldCode = [dict objectForKey:@"oldCode"];
        set.releaseDate = [self parseDate:[dict objectForKey:@"releaseDate"] withFormat:@"YYYY-MM-dd"];
        set.border = [self capitalizeFirstLetterOfWords:[dict objectForKey:@"border"]];
        set.type = [self findSetType:[dict objectForKey:@"type"]];
        set.block = [self findBlock:[dict objectForKey:@"block"]];
        set.onlineOnly = [NSNumber numberWithBool:[[dict objectForKey:@"onlineOnly"] boolValue]];
        
        [currentContext MR_save];
    }
    return set;
}

-(SetType*) findSetType:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }

    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSString *cap = [self capitalizeFirstLetterOfWords:name];
    SetType *setType = [SetType MR_findFirstByAttribute:@"name"
                                              withValue:cap];
    
    if (!setType)
    {
        setType = [SetType MR_createEntity];
        setType.name = cap;
        [currentContext MR_save];
    }
    return setType;
}

-(Block*) findBlock:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }
    
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    Block *block = [Block MR_findFirstByAttribute:@"name"
                                        withValue:name];
    
    if (!block)
    {
        block = [Block MR_createEntity];
        block.name = name;
        [currentContext MR_save];
    }
    return block;
}

-(CardRarity*) findCardRarity:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }

    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSString *cap = [self capitalizeFirstLetterOfWords:name];
    CardRarity *cardRarity = [CardRarity MR_findFirstByAttribute:@"name"
                                                       withValue:cap];
    
    if (!cardRarity)
    {
        cardRarity = [CardRarity MR_createEntity];
        cardRarity.name = cap;
        [currentContext MR_save];
    }
    return cardRarity;
}

#pragma mark - Cards parsing

-(NSSet*) parseCards:(NSArray*) array forSet:(Set*) set
{
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSMutableSet *cards = [[NSMutableSet alloc] init];
    
    for (NSDictionary *dict in array)
    {
        Card *card = [Card MR_createEntity];
            
        card.layout = [dict objectForKey:@"layout"];
        card.name = [dict objectForKey:@"name"];
        card.manaCost = [dict objectForKey:@"manaCost"];
        card.convertedManaCost = [NSNumber numberWithFloat:[[dict objectForKey:@"cmc"] floatValue]];
        card.type = [dict objectForKey:@"type"];
        //            card.colors =
//        NSMutableSet *types = [[NSMutableSet alloc] init];
//        for (NSString *type in [dict objectForKey:@"supertypes"])
//        {
//            [types addObject:[self findCardType:type]];
//        }
//        card.superTypes = types;
//        types = [[NSMutableSet alloc] init];
//        for (NSString *type in [dict objectForKey:@"subtypes"])
//        {
//            [types addObject:[self findCardType:type]];
//        }
//        card.subTypes = types;
//        types = [[NSMutableSet alloc] init];
//        for (NSString *type in [dict objectForKey:@"types"])
//        {
//            [types addObject:[self findCardType:type]];
//        }
//        card.types = types;
        card.rarity = [self findCardRarity:[dict objectForKey:@"rarity"]];
        card.text = [dict objectForKey:@"text"];
        card.flavor = [dict objectForKey:@"flavor"];
        card.artist = [self findArtist:[dict objectForKey:@"artist"]];
        card.number = [dict objectForKey:@"number"];
        card.power = [dict objectForKey:@"power"];
        card.toughness = [dict objectForKey:@"toughness"];
        card.loyalty = [NSNumber numberWithInt:[[dict objectForKey:@"loyalty"] intValue]];
        card.multiverseID = [NSNumber numberWithInt:[[dict objectForKey:@"multiverseid"] intValue]];
        card.imageName = [dict objectForKey:@"imageName"];
        card.watermark = [dict objectForKey:@"watermark"];
        card.border = [dict objectForKey:@"border"];
        card.timeshifted = [NSNumber numberWithBool:[[dict objectForKey:@"timeshifted"] boolValue]];
        card.handModifier = [NSNumber numberWithInt:[[dict objectForKey:@"hand"] intValue]];
        card.lifeModifier = [NSNumber numberWithInt:[[dict objectForKey:@"life"] intValue]];
        card.rulings = [self createRulings:[dict objectForKey:@"rulings"] forCard:card];
        card.foreignNames = [self createForeignNames:[dict objectForKey:@"foreignNames"] forCard:card];
        card.printings = [self findSets:[dict objectForKey:@"printings"]];
        card.originalText = [dict objectForKey:@"originalText"];
//        card.originalType = [self findCardType:[dict objectForKey:@"originalType"]];
        card.legalities = [self createLegalities:[dict objectForKey:@"legalities"] forCard:card];
        card.set = set;

        [currentContext MR_save];

        [cards addObject:card];
    }

    return cards;
}

-(CardType*) findCardType:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }
    
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    CardType *cardType = [CardType MR_findFirstByAttribute:@"name"
                                                       withValue:name];
    
    if (!cardType)
    {
        cardType = [CardType MR_createEntity];
        cardType.name = name;
        [currentContext MR_save];
    }
    return cardType;
}

-(Artist*) findArtist:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }
    
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    Artist *artist = [Artist MR_findFirstByAttribute:@"name"
                                                 withValue:name];
    
    if (!artist)
    {
        artist = [Artist MR_createEntity];
        artist.name = name;
        [currentContext MR_save];
    }
    return artist;
}

-(NSSet*) createRulings:(NSArray*) array forCard:(Card*) card
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableSet *set = [[NSMutableSet alloc] init];
    
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    for (NSDictionary *dict in array)
    {
        CardRuling *ruling = [CardRuling MR_createEntity];
        
        for (NSString *key in [dict allKeys])
        {
            if ([key isEqualToString:@"date"])
            {
                ruling.date = [self parseDate:[dict objectForKey:key] withFormat:@"YYYY-MM-dd"];
            }
            else if ([key isEqualToString:@"text"])
            {
                ruling.text = [dict objectForKey:key];
            }
        }
        ruling.card = card;
        [currentContext MR_save];
        [set addObject:ruling];
    }
    
    return set;
}

-(NSSet*) createForeignNames:(NSArray*) array forCard:(Card*) card
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableSet *set = [[NSMutableSet alloc] init];
    
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    for (NSDictionary *dict in array)
    {
        CardForeignName *foreignName = [CardForeignName MR_createEntity];
        
        for (NSString *key in [dict allKeys])
        {
            if ([key isEqualToString:@"language"])
            {
                foreignName.language = [dict objectForKey:key];
            }
            else if ([key isEqualToString:@"name"])
            {
                foreignName.name = [dict objectForKey:key];
            }
        }
        foreignName.card = card;
        [currentContext MR_save];
        [set addObject:foreignName];
    }
    
    return set;
}

-(NSSet*) findSets:(NSArray*) array
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableSet *set = [[NSMutableSet alloc] init];
    
    for (NSString *name in array)
    {
        Set *printing = [Set MR_findFirstByAttribute:@"name"
                                           withValue:name];
        
        if (!printing)
        {
            printing = [Set MR_createEntity];
            
            printing.name = name;
        }
        [set addObject:printing];
    }

    return set;
}

-(NSSet*) createLegalities:(NSDictionary*) dict forCard:(Card*) card
{
    if (!dict || dict.count <= 0)
    {
        return nil;
    }
    
    NSMutableSet *set = [[NSMutableSet alloc] init];
    
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    for (NSString *key in [dict allKeys])
    {
        CardLegality *legality = [CardLegality MR_createEntity];
        
        legality.name = [dict objectForKey:key];
        legality.format = [self findFormat:key];
        legality.card = card;
        [currentContext MR_save];
        [set addObject:legality];
    }
    
    return set;
}

-(Format*) findFormat:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }
    
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    Format *format = [Format MR_findFirstByAttribute:@"name"
                                           withValue:name];
    
    if (!format)
    {
        format = [Format MR_createEntity];
        format.name = name;
        [currentContext MR_save];
    }
    return format;
}

-(void) setNames:(NSArray*)names andVariations:(NSArray*)variations forCard:(NSString*)name
{
    Card *card = [Card MR_findFirstByAttribute:@"name"
                                       withValue:name];
    
    if (card)
    {
        NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSMutableSet *setNames = [[NSMutableSet alloc] init];
        NSMutableSet *setVariations = [[NSMutableSet alloc] init];
        
        for (NSString *x in names)
        {
            Card *xCard = [Card MR_findFirstByAttribute:@"name"
                                              withValue:x];
            if (xCard)
            {
                [setNames addObject:xCard];
            }
        }
        
        for (NSString *x in variations)
        {
            Card *xCard = [Card MR_findFirstByAttribute:@"multiverseID"
                                              withValue:x];
            if (xCard)
            {
                [setVariations addObject:xCard];
            }
        }
        
        card.names = setNames;
        card.variations = setVariations;
        [currentContext MR_save];
    }
}

#pragma mark - Utility methods
-(NSDate*)parseDate:(NSString*)date withFormat:(NSString*) format
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:format];
    return [dateFormat dateFromString:date];
}

-(NSString*)formatDate:(NSDate *)date withFormat:(NSString*) format
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:format];
    return [dateFormat stringFromDate:date];
}

-(NSString*) capitalizeFirstLetterOfWords:(NSString*) phrase
{
    NSMutableArray *newWords = [[NSMutableArray alloc] init];
    NSArray *chunks = [phrase componentsSeparatedByString:@" "];
    
    for (NSString *chunk in chunks)
    {
        if (chunk.length <= 0)
        {
            continue;
        }

        if ([chunk isEqualToString:@"of"] ||
            [chunk isEqualToString:@"the"])
        {
            [newWords addObject:chunk];
        }
        else
        {
            NSString *capitilizedWord = [[[chunk substringToIndex:1] uppercaseString] stringByAppendingString:[chunk substringFromIndex:1]];
            
            [newWords addObject:capitilizedWord];
        }
    }
    
    return [newWords componentsJoinedByString:@" "];
}

@end

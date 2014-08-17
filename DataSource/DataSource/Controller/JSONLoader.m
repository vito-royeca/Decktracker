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
        Set *set = [self parseSet:dict];

        for (NSDictionary *dictCard in [dict objectForKey:@"cards"])
        {
            Card *card = [[Database sharedInstance] findCard:[dictCard objectForKey:@"name"] inSet:set.code];
            
            if (card)
            {
                card.rulings = [self createRulings:[dictCard objectForKey:@"rulings"]];
                card.foreignNames = [self createForeignNames:[dictCard objectForKey:@"foreignNames"]];
//                card.legalities = [self createLegalities:[dictCard objectForKey:@"legalities"]];
                [currentContext MR_save];
            }
        }
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
        set.releaseDate = [JJJUtil parseDate:[dict objectForKey:@"releaseDate"] withFormat:@"YYYY-MM-dd"];
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

    NSString *cap = [self capitalizeFirstLetterOfWords:name];
    SetType *setType = [SetType MR_findFirstByAttribute:@"name"
                                              withValue:cap];
    
    if (!setType)
    {
        setType = [SetType MR_createEntity];
        setType.name = cap;
    }
    return setType;
}

-(Block*) findBlock:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }
    
    Block *block = [Block MR_findFirstByAttribute:@"name"
                                        withValue:name];
    
    if (!block)
    {
        block = [Block MR_createEntity];
        block.name = name;
    }
    return block;
}

-(CardRarity*) findCardRarity:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }

    NSString *cap = [self capitalizeFirstLetterOfWords:name];
    CardRarity *cardRarity = [CardRarity MR_findFirstByAttribute:@"name"
                                                       withValue:cap];
    
    if (!cardRarity)
    {
        cardRarity = [CardRarity MR_createEntity];
        cardRarity.name = cap;
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
        card.cmc = [NSNumber numberWithFloat:[[dict objectForKey:@"cmc"] floatValue]];
        card.type = [dict objectForKey:@"type"];
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
        card.printings = [self findSets:[dict objectForKey:@"printings"]];
        card.originalText = [dict objectForKey:@"originalText"];
        card.lifeModifier = [NSNumber numberWithInt:[[dict objectForKey:@"life"] intValue]];
        card.types = [self findTypes:[dict objectForKey:@"types"]];
        card.superTypes = [self findTypes:[dict objectForKey:@"supertypes"]];
        card.subTypes = [self findTypes:[dict objectForKey:@"subtypes"]];
        card.set = set;

        [currentContext MR_save];

        [cards addObject:card];
    }

    return cards;
}

-(Artist*) findArtist:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }
    
    Artist *artist = [Artist MR_findFirstByAttribute:@"name"
                                                 withValue:name];
    
    if (!artist)
    {
        artist = [Artist MR_createEntity];
        artist.name = name;
    }
    return artist;
}

-(NSSet*) createRulings:(NSArray*) array
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableSet *set = [[NSMutableSet alloc] init];
    
    for (NSDictionary *dict in array)
    {
        CardRuling *ruling = [CardRuling MR_createEntity];
        
        for (NSString *key in [dict allKeys])
        {
            if ([key isEqualToString:@"date"])
            {
                ruling.date = [JJJUtil parseDate:[dict objectForKey:key] withFormat:@"YYYY-MM-dd"];
            }
            else if ([key isEqualToString:@"text"])
            {
                ruling.text = [dict objectForKey:key];
            }
        }
        [set addObject:ruling];
    }
    
    return set;
}

-(NSSet*) createForeignNames:(NSArray*) array
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableSet *set = [[NSMutableSet alloc] init];
    
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

-(NSSet*) findTypes:(NSArray*) array
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableSet *set = [[NSMutableSet alloc] init];
    
    for (NSString *name in array)
    {
        CardType *type = [CardType MR_findFirstByAttribute:@"name"
                                                 withValue:name];
        
        if (!type)
        {
            type = [CardType MR_createEntity];
            
            type.name = name;
        }
        [set addObject:type];
    }
    
    return set;
}

-(NSSet*) createLegalities:(NSDictionary*) dict
{
    if (!dict || dict.count <= 0)
    {
        return nil;
    }
    
    NSMutableSet *set = [[NSMutableSet alloc] init];
    
    for (NSString *key in [dict allKeys])
    {
        CardLegality *legality = [CardLegality MR_createEntity];
        
        legality.name = [dict objectForKey:key];
        legality.format = [self findFormat:key];
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
    
    Format *format = [Format MR_findFirstByAttribute:@"name"
                                           withValue:name];
    
    if (!format)
    {
        format = [Format MR_createEntity];
        format.name = name;
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

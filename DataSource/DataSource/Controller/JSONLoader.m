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
#import "CardColor.h"
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
{
    int _cardID;
}

-(void) parseJSON
{
    NSDate *dateStart = [NSDate date];
    [[Database sharedInstance] setupDb];
    _cardID = 1;

    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Data/AllSets-x.json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

//    [self parseCards1stPass:json];
    [self parseCards2ndPass:json];
    [[Database sharedInstance] closeDb];
    
    NSDate *dateEnd = [NSDate date];
    NSTimeInterval timeDifference = [dateEnd timeIntervalSinceDate:dateStart];
    NSLog(@"Started: %@", dateStart);
    NSLog(@"Ended: %@", dateEnd);
    NSLog(@"Time Elapsed: %@",  [JJJUtil formatInterval:timeDifference]);
}

-(void) parseCards1stPass:(NSDictionary*) json
{
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];

    for (NSString *setName in [json allKeys])
    {
        NSDictionary * dict = json[setName];
        [self parseSet:dict];
        [currentContext MR_save];
    }
    [self updateTCGSetNames];
    
    for (NSString *setName in [json allKeys])
    {
        NSDictionary * dict = json[setName];
        Set *set = [self parseSet:dict];
        NSSet *cards = [self parseCards:dict[@"cards"] forSet:set];
        set.numberOfCards = [NSNumber numberWithInt:(int)cards.count];
        [currentContext MR_save];
        
        for (NSDictionary *dictCard in dict[@"cards"])
        {
            Card *card;
            
            if (dictCard[@"multiverseID"])
            {
                card = [Card MR_findFirstByAttribute:@"multiverseID" withValue:dictCard[@"multiverseID"]];
            }
            if (!card)
            {
                card = [[Database sharedInstance] findCard:dictCard[@"name"] inSet:set.code];
            }
            
            if (card)
            {
                card.rulings = [self createRulings:dictCard[@"rulings"]];
                card.foreignNames = [self createForeignNames:dictCard[@"foreignNames"]];
                
                NSArray *names = dictCard[@"names"];
                NSArray *variations = dictCard[@"variations"];
                
                if (names.count > 0 || variations.count > 0)
                {
                    [self setNames:names andVariations:variations forCard:card];
                }
                [currentContext MR_save];
            }
        }
    }
    
    // Create colorless CardColor
    CardColor *color = [CardColor MR_createEntity];
    color.name = @"Colorless";
    [currentContext MR_save];
}

-(void) parseCards2ndPass:(NSDictionary*) json
{
    for (NSString *setName in [json allKeys])
    {
        NSDictionary * dict = json[setName];
        Set *set = [self parseSet:dict];
        
        for (NSDictionary *dictCard in dict[@"cards"])
        {
            NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
            
            Card *card;
            
            if (dictCard[@"multiverseID"])
            {
                card = [Card MR_findFirstByAttribute:@"multiverseID" withValue:dictCard[@"multiverseID"]];
            }
            if (!card)
            {
                card = [[Database sharedInstance] findCard:dictCard[@"name"] inSet:set.code];
            }
            
            if (!card.legalities || card.legalities.count == 0)
            {
                card.legalities = [self createLegalities:dictCard[@"legalities"]];
                [currentContext MR_save];
            }
        }
    }
}

-(void) updateTCGSetNames
{
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Data/tcgplayer_sets.plist"];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
    NSDictionary *tcgNames = array[0];
    
    for (Set *set in [Set MR_findAll])
    {
        NSString *tcgName;
        
        if ([set.name rangeOfString:@" vs. "].location != NSNotFound)
        {
            tcgName = [set.name stringByReplacingOccurrencesOfString:@" vs. " withString:@" vs "];
        }
        else
        {
            tcgName = [tcgNames objectForKey:set.name];
        }
        
        set.tcgPlayerName = tcgName ? tcgName : set.name;
        
        [currentContext MR_save];
    }
}

-(void) updateDeckInAppSettings
{
    // copy formats...
    NSString *command = @"/usr/libexec/PlistBuddy";
    NSString *destFile = @"\"/Users/tontonsevilla/deck.inApp.plist\"";
    
    NSString *deleteOp = [NSString stringWithFormat:@"%@ %@ -c \"Delete PreferenceSpecifiers:3:Titles\"", command, destFile];
    [JJJUtil runCommand:deleteOp];
    deleteOp = [NSString stringWithFormat:@"%@ %@ -c \"Delete PreferenceSpecifiers:3:Values\"", command, destFile];
    [JJJUtil runCommand:deleteOp];
    
    NSString *addOp = [NSString stringWithFormat:@"%@ %@ -c \"Add PreferenceSpecifiers:3:Titles array\"", command, destFile];
    [JJJUtil runCommand:addOp];
    addOp = [NSString stringWithFormat:@"%@ %@ -c \"Add PreferenceSpecifiers:3:Values array\"", command, destFile];
    [JJJUtil runCommand:addOp];
    
    
    NSArray *arrFormats = [Format MR_findAllSortedBy:@"name" ascending:YES];
    int i=0;
    for (Format *format in arrFormats)
    {
        NSString *op = [NSString stringWithFormat:@"%@ %@ -c \"Add PreferenceSpecifiers:3:Titles:%d string '%@'\"", command, destFile, i, format.name];
        [JJJUtil runCommand:op];
        i++;
    }
    
    i=0;
    for (Format *format in arrFormats)
    {
        NSString *op = [NSString stringWithFormat:@"%@ %@ -c \"Add PreferenceSpecifiers:3:Values:%d string '%@'\"", command, destFile, i, format.name];
        [JJJUtil runCommand:op];
        i++;
    }
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
                                  withValue:dict[@"name"]];
    
    if (!set)
    {
        set = [Set MR_createEntity];
        
        set.name = dict[@"name"];
        set.code = dict[@"code"];
        set.gathererCode = dict[@"gathererCode"];
        set.oldCode = dict[@"oldCode"];
        set.releaseDate = [JJJUtil parseDate:dict[@"releaseDate"] withFormat:@"YYYY-MM-dd"];
        set.border = [self capitalizeFirstLetterOfWords:dict[@"border"]];
        set.type = [self findSetType:dict[@"type"]];
        set.block = [self findBlock:dict[@"block"]];
        set.onlineOnly = [NSNumber numberWithBool:[dict[@"onlineOnly"] boolValue]];
        
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
        
        card.cardID = [NSNumber numberWithInt:_cardID];
        card.layout = dict[@"layout"];
        card.name = dict[@"name"];
        card.manaCost = dict[@"manaCost"];
        card.cmc = [NSNumber numberWithFloat:[dict[@"cmc"] floatValue]];
        card.type = dict[@"type"];
        card.rarity = [self findCardRarity:dict[@"rarity"]];
        card.text = dict[@"text"];
        card.flavor = dict[@"flavor"];
        card.artist = [self findArtist:dict[@"artist"]];
        card.number = dict[@"number"];
        card.power = dict[@"power"];
        card.toughness = dict[@"toughness"];
        card.loyalty = [NSNumber numberWithInt:[dict[@"loyalty"] intValue]];
        card.multiverseID = [NSNumber numberWithInt:[dict[@"multiverseid"] intValue]];
        card.imageName = dict[@"imageName"];
        card.watermark = dict[@"watermark"];
        card.source = dict[@"source"];
        card.border = dict[@"border"];
        card.timeshifted = [NSNumber numberWithBool:[dict[@"timeshifted"] boolValue]];
        card.reserved = [NSNumber numberWithBool:[dict[@"reserved"] boolValue]];
        card.releaseDate = dict[@"releaseDate"];
        card.handModifier = [NSNumber numberWithInt:[dict[@"hand"] intValue]];
        card.printings = [self findSets:dict[@"printings"]];
        card.originalText = dict[@"originalText"];
        card.originalType = dict[@"originalType"];
        card.lifeModifier = [NSNumber numberWithInt:[dict[@"life"] intValue]];
        card.types = [self findTypes:dict[@"types"]];
        card.superTypes = [self findTypes:dict[@"supertypes"]];
        card.subTypes = [self findTypes:dict[@"subtypes"]];
        card.colors = [self findColors:dict[@"colors"]];
        card.set = set;

        [currentContext MR_save];

        [cards addObject:card];
        _cardID++;
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
                ruling.date = [JJJUtil parseDate:dict[key] withFormat:@"YYYY-MM-dd"];
            }
            else if ([key isEqualToString:@"text"])
            {
                ruling.text = dict[key];
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
                foreignName.language = dict[key];
            }
            else if ([key isEqualToString:@"name"])
            {
                foreignName.name = dict[key];
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

-(NSSet*) findColors:(NSArray*) array
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableSet *set = [[NSMutableSet alloc] init];
    
    for (NSString *name in array)
    {
        CardColor *color = [CardColor MR_findFirstByAttribute:@"name"
                                                    withValue:name];
        
        if (!color)
        {
            color = [CardColor MR_createEntity];
            
            color.name = name;
        }
        [set addObject:color];
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
        
        legality.name = dict[key];
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

-(void) setNames:(NSArray*)names andVariations:(NSArray*)variations forCard:(Card*)card
{
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

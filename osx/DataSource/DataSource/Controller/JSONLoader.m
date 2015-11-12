//
//  JSONLoader.m
//  DataSource
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "JSONLoader.h"
#import "Constants.h"
#import "Database.h"

#import <JJJUtils/JJJ.h>

#import "TFHpple.h"

@implementation JSONLoader
{
    NSMutableDictionary *_dictMagicCardsInfo;
    NSDate *_8thEditionReleaseDate;
}

-(void) json2Database
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Data/AllSets-x.json"];
    NSLog(@"filePath=%@", filePath);
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    _dictMagicCardsInfo = [[NSMutableDictionary alloc] init];
    _8thEditionReleaseDate = [JJJUtil parseDate:EIGHTH_EDITION_RELEASE withFormat:@"YYYY-MM-dd"];

    [[Database sharedInstance] setupDb];
    
    // Create additional CardColor
    [self createAdditionalColor:@"Colorless"];
    [self createAdditionalColor:@"Multicolored"];
    
    // parse the sets
    for (NSString *setName in [json allKeys])
    {
        NSDictionary * dict = json[setName];
        [self parseSet:dict];
    }
    
    // parse the cards
    for (NSString *setName in [json allKeys])
    {
        NSDictionary *dict = json[setName];
        DTSet *set = [self parseSet:dict];
//        if (![set.code isEqualToString:@"LEA"])
//        {
//            continue;
//        }
        
        NSArray *cards = [self parseCards:dict[@"cards"] forSet:set];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        set.numberOfCards = (int)cards.count;
        [realm commitWriteTransaction];
        
        [_dictMagicCardsInfo removeObjectForKey:set.magicCardsInfoCode];
    }

    // Done
    [[Database sharedInstance] closeDb];
}

-(DTCardColor*) createAdditionalColor:(NSString*) colorName
{
    DTCardColor *color = [[DTCardColor objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", colorName]] firstObject];
    if (!color)
    {
        color = [[DTCardColor alloc] init];
        color.name = colorName;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        //        NSLog(@"+CardColor: %@", name);
        [realm addObject:color];
        [realm commitWriteTransaction];
    }
    return color;
}

#pragma mark - Update methods
-(void) updateCardPricing
{
    [[Database sharedInstance] setupDb];
    
    NSArray *sorters = @[[RLMSortDescriptor sortDescriptorWithProperty:@"releaseDate" ascending:YES],
                         [RLMSortDescriptor sortDescriptorWithProperty:@"name" ascending:YES]];
    for (DTCard  *card in [[DTCard allObjects] sortedResultsUsingDescriptors:sorters])
    {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [[Database sharedInstance] fetchTcgPlayerPriceForCard:card.cardId];
        [realm commitWriteTransaction];
    }
    
    // Done
    [[Database sharedInstance] closeDb];
}

-(void) updateTcgPlayerNameOfSet:(DTSet*) set
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Data/tcgplayer_sets.plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    set.tcgPlayerName = [dict objectForKey:set.name] ? [dict objectForKey:set.name] : @"";
}

-(void) updateNumberOfCard:(DTCard*) card
{
    NSMutableDictionary *dict = _dictMagicCardsInfo[card.set.magicCardsInfoCode];
    
    if (!dict && card.set.magicCardsInfoCode.length > 0)
    {
        NSString *url = [[NSString stringWithFormat:@"http://magiccards.info/%@/en.html", card.set.magicCardsInfoCode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        TFHpple *parser = [TFHpple hppleWithHTMLData:data];
        
        dict = [[NSMutableDictionary alloc] init];
        [dict addEntriesFromDictionary:[self parseCardNumber:[parser searchWithXPathQuery:@"//tr[@class='even']"]]];
        [dict addEntriesFromDictionary:[self parseCardNumber:[parser searchWithXPathQuery:@"//tr[@class='odd']"]]];
        
        [_dictMagicCardsInfo setObject:dict forKey:card.set.magicCardsInfoCode];
    }
    
    if (card.number.length > 0 || card.set.magicCardsInfoCode.length <= 0)
    {
        [dict removeObjectForKey:card.number];
        return;
    }
    
    for (NSString *key in [dict allKeys])
    {
        if ([[card.name lowercaseString] isEqualToString:[dict[key] lowercaseString]])
        {
            card.number = key;
            break;
        }
    }
    
    [dict removeObjectForKey:card.number];
}

-(NSDictionary*) parseCardNumber:(NSArray*) nodes
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for (TFHppleElement *tr in nodes)
    {
        NSString *number;
        NSString *name;
        
        for (TFHppleElement *td in tr.children)
        {
            if ([[td tagName] isEqualToString:@"td"])
            {
//                for (TFHppleElement *elem in td.children)
//                {
                    if (!number)
                    {
                        number = [[td firstChild] content];
                    }
                    if (!name)
                    {
                        for (TFHppleElement *elem in td.children)
                        {
                            name = [[elem firstChild] content];
                        }
                    }
                    
//                }
                
                if (number && name)
                {
                    [dict setObject:name forKey:number];
                    break;
                }
            }
        }
    }
    
    return dict;
}

#pragma mark - Sets parsing
-(DTSet*) parseSet:(NSDictionary*) dict
{
    if (!dict || dict.count == 0)
    {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy";
    
    DTSet *set = [[DTSet objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", dict[@"name"]]] firstObject];
    
    if (!set)
    {
        set = [[DTSet alloc] init];
        if (dict[@"border"] && [dict[@"border"] class] != [NSNull class])
        {
            set.border = [self capitalizeFirstLetterOfWords:dict[@"border"]];
        }
        if (dict[@"code"] && [dict[@"code"] class] != [NSNull class])
        {
            set.code =  dict[@"code"];
        }
        if (dict[@"gathererCode"] && [dict[@"gathererCode"] class] != [NSNull class])
        {
            set.gathererCode =  dict[@"gathererCode"];
        }
        if (dict[@"magicCardsInfoCode"] && [dict[@"magicCardsInfoCode"] class] != [NSNull class])
        {
            set.magicCardsInfoCode = dict[@"magicCardsInfoCode"];
        }
        if (dict[@"name"] && [dict[@"name"] class] != [NSNull class])
        {
            set.name = dict[@"name"];
            set.sectionNameInitial = ([JJJUtil isAlphaStart:set.name] ?  [set.name substringToIndex:1] : @"#");
        }
        if (dict[@"oldCode"] && [dict[@"oldCode"] class] != [NSNull class])
        {
            set.oldCode = dict[@"oldCode"];
        }
        if (dict[@"onlineOnly"] && [dict[@"onlineOnly"] class] != [NSNull class])
        {
            set.onlineOnly = [dict[@"onlineOnly"] boolValue];
        }
        if (dict[@"releaseDate"] && [dict[@"releaseDate"] class] != [NSNull class])
        {
            set.releaseDate =  [JJJUtil parseDate:dict[@"releaseDate"] withFormat:@"YYYY-MM-dd"];
            set.sectionYear =  [formatter stringFromDate:set.releaseDate];
        }
        [self updateTcgPlayerNameOfSet:set];
        if (dict[@"block"] && [dict[@"block"] class] != [NSNull class])
        {
            set.block = [self findBlock:dict[@"block"]];
        }
        if (dict[@"type"] && [dict[@"type"] class] != [NSNull class])
        {
            set.type = [self findSetType:dict[@"type"]];
        }
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
//        NSLog(@"+Set: %@", set.name);
        [realm addObject:set];
        [realm commitWriteTransaction];
    }
    return set;
}

-(DTSetType*) findSetType:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }

    NSString *cap = [self capitalizeFirstLetterOfWords:name];
    DTSetType *setType = [[DTSetType objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", cap]] firstObject];
    
    if (!setType)
    {
        setType = [[DTSetType alloc] init];
        setType.name = cap;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
//        NSLog(@"+SetType: %@", cap);
        [realm addObject:setType];
        [realm commitWriteTransaction];
    }
    return setType;
}

-(DTBlock*) findBlock:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }
    
    DTBlock *block = [[DTBlock objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]] firstObject];
    if (!block)
    {
        block = [[DTBlock alloc] init];
        block.name = name;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
//        NSLog(@"+Block: %@", name);
        [realm addObject:block];
        [realm commitWriteTransaction];
    }
    return block;
}

-(NSArray*) findSets:(NSArray*) array
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (NSString *code in array)
    {
        DTSet *printing = [[DTSet objectsWithPredicate:[NSPredicate predicateWithFormat:@"code = %@", code]] firstObject];
        
        if (printing)
        {
            [results addObject:printing];
        }
    }
    
    return results;
}

-(NSArray*) findLanguages:(NSArray*) array
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (NSString *name in array)
    {
        DTLanguage *language = [[DTLanguage objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]] firstObject];
        
        if (!language)
        {
            language = [[DTLanguage alloc] init];
            language.name = name;
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
//            NSLog(@"+Language: %@", name);
            [realm addObject:language];
            [realm commitWriteTransaction];
        }
        [results addObject:language];
    }
    
    return results;
}

#pragma mark - Cards parsing
-(NSArray*) parseCards:(NSArray*) array forSet:(DTSet*) set
{
    NSMutableArray *cards = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in array)
    {
        DTCard *card;
        int multiverseID = -1;
        NSString *number = @"";
        
        if (dict[@"multiverseid"] && [dict[@"multiverseid"] class] != [NSNull class])
        {
            multiverseID = [dict[@"multiverseid"] intValue];
            card = [[DTCard objectsWithPredicate:[NSPredicate predicateWithFormat:@"multiverseID = %@", dict[@"multiverseid"]]] firstObject];
        }
        if (dict[@"number"] && [dict[@"number"] class] != [NSNull class])
        {
            number = dict[@"number"];
            if (!card)
            {
                card = [[DTCard objectsWithPredicate:[NSPredicate predicateWithFormat:@"set.code = %@ AND number = %@", set.code, number]] firstObject];
            }
        }
        if (!card)
        {
            card = [[DTCard objectsWithPredicate:[NSPredicate predicateWithFormat:@"set.code = %@ AND name = %@", set.code, dict[@"name"]]] firstObject];
        }

        // create new card if not found
        if (!card)
        {
            card = [[DTCard alloc] init];
            card.set = set;
            card.cardId = dict[@"id"];
            
            if (dict[@"border"] && [dict[@"border"] class] != [NSNull class])
            {
                card.border = dict[@"border"];
            }
            if (dict[@"cmc"] && [dict[@"cmc"] class] != [NSNull class])
            {
                card.cmc = [dict[@"cmc"] floatValue];
            }
            if (dict[@"flavor"] && [dict[@"flavor"] class] != [NSNull class])
            {
                card.flavor = dict[@"flavor"];
            }
            if (dict[@"hand"] && [dict[@"hand"] class] != [NSNull class])
            {
                card.handModifier = [dict[@"hand"] intValue];
            }
            if (dict[@"imageName"] && [dict[@"imageName"] class] != [NSNull class])
            {
                card.imageName = dict[@"imageName"];
            }
            if (dict[@"layout"] && [dict[@"layout"] class] != [NSNull class])
            {
                card.layout = dict[@"layout"];
            }
            if (dict[@"life"] && [dict[@"life"] class] != [NSNull class])
            {
                card.lifeModifier = [dict[@"life"] intValue];
            }
            if (dict[@"loyalty"] && [dict[@"loyalty"] class] != [NSNull class])
            {
                card.loyalty = [dict[@"loyalty"] intValue];
            }
            if (dict[@"manaCost"] && [dict[@"manaCost"] class] != [NSNull class])
            {
                card.manaCost = dict[@"manaCost"];
            }
            card.multiverseID = multiverseID;
            if (dict[@"name"] && [dict[@"name"] class] != [NSNull class])
            {
                card.name = dict[@"name"];
                card.sectionNameInitial = ([JJJUtil isAlphaStart:card.name] ?  [card.name substringToIndex:1] : @"#");
            }
            card.number = number;
            if (card.number.length == 0)
            {
                [self updateNumberOfCard:card];
            }
            if (dict[@"originalText"] && [dict[@"originalText"] class] != [NSNull class])
            {
                card.originalText = dict[@"originalText"];
            }
            if (dict[@"originalType"] && [dict[@"originalType"] class] != [NSNull class])
            {
                card.originalType = dict[@"originalType"];
            }
            if (dict[@"power"] && [dict[@"power"] class] != [NSNull class])
            {
                card.power = dict[@"power"];
            }
            
            if (dict[@"releaseDate"] && [dict[@"releaseDate"] class] != [NSNull class])
            {
                card.releaseDate = dict[@"releaseDate"];
                
                NSString *format = @"YYYY-MM-dd";
                NSString *tempReleaseDate;
                NSDate *releaseDate;
                
                if (card.releaseDate.length == 4)
                {
                    tempReleaseDate = [NSString stringWithFormat:@"%@-01-01", card.releaseDate];
                }
                else if (card.releaseDate.length == 7)
                {
                    tempReleaseDate = [NSString stringWithFormat:@"%@-01", card.releaseDate];
                }
                releaseDate = [JJJUtil parseDate:(tempReleaseDate ? tempReleaseDate : card.releaseDate)
                                      withFormat:format];
                
                card.modern = [releaseDate compare:_8thEditionReleaseDate] == NSOrderedSame ||
                [releaseDate compare:_8thEditionReleaseDate] == NSOrderedDescending;
            }
            else
            {
                NSDate *releaseDate = set.releaseDate;
                card.modern = [releaseDate compare:_8thEditionReleaseDate] == NSOrderedSame ||
                [releaseDate compare:_8thEditionReleaseDate] == NSOrderedDescending;
            }
            if (dict[@"reserved"] && [dict[@"reserved"] class] != [NSNull class])
            {
                card.reserved = [dict[@"reserved"] boolValue];
            }
            if (dict[@"source"] && [dict[@"source"] class] != [NSNull class])
            {
                card.source = dict[@"source"];
            }
            if (dict[@"starter"] && [dict[@"starter"] class] != [NSNull class])
            {
                card.starter = [dict[@"starter"] boolValue];
            }
            if (dict[@"text"] && [dict[@"text"] class] != [NSNull class])
            {
                card.text = dict[@"text"];
            }
            if (dict[@"timeshifted"] && [dict[@"timeshifted"] class] != [NSNull class])
            {
                card.timeshifted = [dict[@"timeshifted"] boolValue];
            }
            if (dict[@"toughness"] && [dict[@"toughness"] class] != [NSNull class])
            {
                card.toughness = dict[@"toughness"];
            }
            if (dict[@"type"] && [dict[@"type"] class] != [NSNull class])
            {
                card.type = dict[@"type"];
            }
            if (dict[@"watermark"] && [dict[@"watermark"] class] != [NSNull class])
            {
                card.watermark = dict[@"watermark"];
            }
            [card.colors addObjects:[self findColors:dict[@"colors"]]];
            if (!card.colors || card.colors.count == 0)
            {
                card.sectionColor = @"Colorless";
            }
            else if (card.colors.count > 1)
            {
                card.sectionColor = @"Multicolored";
            }
            else if (card.colors.count == 1)
            {
                DTCardColor *color = [card.colors firstObject];
                
                for (NSString *colorName in CARD_COLORS)
                {
                    if ([color.name isEqualToString:colorName])
                    {
                        card.sectionColor = color.name;
                        break;
                    }
                }
            }
            if (dict[@"artist"] && [dict[@"artist"] class] != [NSNull class])
            {
                card.artist = [self findArtist:dict[@"artist"]];
            }
            [card.printings addObjects:[self findSets:dict[@"printings"]]];
            if (dict[@"rarity"] && [dict[@"rarity"] class] != [NSNull class])
            {
                card.rarity = [self findCardRarity:dict[@"rarity"]];
            }
            [card.subTypes addObjects:[self findTypes:dict[@"subtypes"]]];
            [card.superTypes addObjects:[self findTypes:dict[@"supertypes"]]];
            [card.types addObjects:[self findTypes:dict[@"types"]]];
            for (DTCardType *type in card.types)
            {
                for (NSString *typeName in CARD_TYPES)
                {
                    // done: fix Plane and Planeswalker types!!!
                    if ([typeName isEqualToString:type.name] || [typeName containsString:type.name])
                    {
                        card.sectionType = typeName;
                        break;
                    }
                }
                
                if (card.sectionType)
                {
                    break;
                }
            }
            
            NSArray *names = dict[@"names"];
            NSArray *variations = dict[@"variations"];
            if (names.count > 0 || variations.count > 0)
            {
                [self setNames:names andVariations:variations forCard:card];
            }
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            //        NSLog(@"+Card: %@ [%@] - %@", set.name, set.code, card.name);
            [realm addObject:card];
            [realm commitWriteTransaction];
            
            [self createRulingsForCard:card withRulings:dict[@"rulings"]];
            [self createForeignNamesForCard:card withLanguages:dict[@"foreignNames"]];
            [self createLegalitiesForCard:card withLegalities:dict[@"legalities"]];
            [[Database sharedInstance] fetchTcgPlayerPriceForCard:card.cardId];
        }
        
        [cards addObject:card.cardId];
    }

    return cards;
}

-(NSArray*) findColors:(NSArray*) array
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (NSString *name in array)
    {
        DTCardColor *color = [[DTCardColor objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]] firstObject];
        
        if (!color)
        {
            color = [[DTCardColor alloc] init];
            color.name = name;
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
//            NSLog(@"+CardColor: %@", name);
            [realm addObject:color];
            [realm commitWriteTransaction];
        }
        [results addObject:color];
    }
                                
    return results;
}

-(DTArtist*) findArtist:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }
    
    DTArtist *artist = [[DTArtist objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]] firstObject];
    
    if (!artist)
    {
        artist = [[DTArtist alloc] init];
        artist.name = name;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
//        NSLog(@"+Artist: %@", name);
        [realm addObject:artist];
        [realm commitWriteTransaction];
    }
    return artist;
}

-(DTCardRarity*) findCardRarity:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }
    
    NSString *cap = [self capitalizeFirstLetterOfWords:name];
    DTCardRarity *cardRarity = [[DTCardRarity objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", cap]] firstObject];
    
    if (!cardRarity)
    {
        cardRarity = [[DTCardRarity alloc] init];
        cardRarity.name = cap;
        if ([cap isEqualToString:@"Basic Land"])
        {
            cardRarity.symbol = @"C";
        }
        else
        {
            cardRarity.symbol = [cap substringToIndex:1];
        }
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
//        NSLog(@"+CardRarity: %@", name);
        [realm addObject:cardRarity];
        [realm commitWriteTransaction];
    }
    return cardRarity;
}

-(NSArray*) findTypes:(NSArray*) array
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (NSString *name in array)
    {
        DTCardType *type = [[DTCardType objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]] firstObject];
        
        if (!type)
        {
            type = [[DTCardType alloc] init];
            type.name = name;
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
//            NSLog(@"+CardType: %@", name);
            [realm addObject:type];
            [realm commitWriteTransaction];
        }
        [results addObject:type];
    }
    
    return results;
}


-(NSArray*) createRulingsForCard:(DTCard*)card withRulings:(NSArray*) array
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableArray *rulings = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in array)
    {
        DTCardRuling *ruling = [[DTCardRuling alloc] init];
        ruling.card = card;
        
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
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
//        NSLog(@"+CardRuling: %@", [JJJUtil formatDate:ruling.date withFormat:@"YYYY-MM-dd"]);
        [realm addObject:ruling];
        [realm commitWriteTransaction];
        
        [rulings addObject:ruling];
    }
    
    return rulings;
}

-(NSArray*) createForeignNamesForCard:(DTCard*) card withLanguages:(NSArray*) array
{
    if (!array || array.count <= 0)
    {
        return nil;
    }
    
    NSMutableArray *foreignNames = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in array)
    {
        DTCardForeignName *foreignName = [[DTCardForeignName alloc] init];
        foreignName.card = card;
        
        for (NSString *key in [dict allKeys])
        {
            if ([key isEqualToString:@"language"])
            {
                foreignName.language = [[self findLanguages:@[dict[key]]] firstObject];
            }
            else if ([key isEqualToString:@"name"])
            {
                foreignName.name = dict[key];
            }
        }
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        //            NSLog(@"+ForeignName: %@", foreignName.name);
        [realm addObject:foreignName];
        [realm commitWriteTransaction];
        
        [foreignNames addObject:foreignName];
    }
    
    return foreignNames;
}

-(void) setNames:(NSArray*)names andVariations:(NSArray*)variations forCard:(DTCard*)card
{
    NSMutableArray *arrNames = [[NSMutableArray alloc] init];
    NSMutableSet *arrVariations = [[NSMutableSet alloc] init];
    
    for (NSString *x in names)
    {
        DTCard *xCard = [[DTCard objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", x]] firstObject];
        
        if (xCard)
        {
            [arrNames addObject:xCard];
        }
    }
    
    for (NSString *x in variations)
    {
        DTCard *xCard = [[DTCard objectsWithPredicate:[NSPredicate predicateWithFormat:@"multiverseID = %@", x]] firstObject];
        
        if (xCard)
        {
            [arrVariations addObject:xCard];
        }
    }
    
    [card.names addObjects:arrNames];
    [card.variations addObjects:arrVariations];
}

-(NSArray*) createLegalitiesForCard:(DTCard*)card withLegalities:(NSArray*) arr
{
    if (!arr || arr.count <= 0)
    {
        return nil;
    }
    
    NSMutableArray *legalities = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in arr)
    {
        for (NSString *key in [dict allKeys])
        {
            DTCardLegality *legality = [[DTCardLegality alloc] init];
            
            legality.card = card;
            legality.name = dict[key];
            legality.format = [self findFormat:key];
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
//            NSLog(@"+CardLegality: %@", legality.name);
            [realm addObject:legality];
            [realm commitWriteTransaction];
            
            [legalities addObject:legality];
        }
    }
    return legalities;
}

-(DTFormat*) findFormat:(NSString*) name
{
    if (!name || name.length == 0)
    {
        return nil;
    }
    
    DTFormat *format = [[DTFormat objectsWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]] firstObject];
    
    if (!format)
    {
        format = [[DTFormat alloc] init];
        format.name = name;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
//        NSLog(@"+Format: %@", format);
        [realm addObject:format];
        [realm commitWriteTransaction];
    }
    
    return format;
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

/*
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
    
    
    NSArray *arrFormats = [DTFormat MR_findAllSortedBy:@"name" ascending:YES];
    int i=0;
    for (DTFormat *format in arrFormats)
    {
        NSString *op = [NSString stringWithFormat:@"%@ %@ -c \"Add PreferenceSpecifiers:3:Titles:%d string '%@'\"", command, destFile, i, format.name];
        [JJJUtil runCommand:op];
        i++;
    }
    
    i=0;
    for (DTFormat *format in arrFormats)
    {
        NSString *op = [NSString stringWithFormat:@"%@ %@ -c \"Add PreferenceSpecifiers:3:Values:%d string '%@'\"", command, destFile, i, format.name];
        [JJJUtil runCommand:op];
        i++;
    }
}
*/
@end

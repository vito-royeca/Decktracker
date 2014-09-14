//
//  ImageLoader.m
//  DataSource
//
//  Created by Jovit Royeca on 8/3/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "ImageLoader.h"
#import "JJJ/JJJUtil.h"
#import "Card.h"
#import "CardRarity.h"
#import "Database.h"
#import "Magic.h"
#import "Set.h"

@implementation ImageLoader

-(void) downloadSymbols
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/images-raw/mana"];
    
    [self createDir:path];
    
    for (NSString *mana in kManaSymbols)
    {
        NSString *dirPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", mana]];
        [self createDir:dirPath];
        
        for (NSString *size in kImageSizes)
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mtgimage.com/symbol/mana/%@/%@.png", mana, size]];
            NSString *filePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.png", size]];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                NSLog(@"Downloading... %@", url);
                [JJJUtil downloadResource:url toPath:filePath];
            }
        }
    }
}

-(void) downloadOtherSymbols
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/images-raw/other"];
    
    [self createDir:path];
    
    for (NSString *other in kOtherSymbols)
    {
        NSString *dirPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", other]];
        [self createDir:dirPath];
        
        for (NSString *size in kImageSizes)
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mtgimage.com/symbol/other/%@/%@.png", other, size]];
            NSString *filePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.png", size]];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                NSLog(@"Downloading... %@", url);
                [JJJUtil downloadResource:url toPath:filePath];
            }
        }
    }
}

-(void) downloadAllSets
{
    [[Database sharedInstance] setupDb];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/images-raw/set"];
    NSArray *rarities = @[@"C", @"U", @"R", @"M", @"S"];
    
    [self createDir:path];
    
    for (Set *set in [Set MR_findAllSortedBy:@"releaseDate" ascending:YES])
    {
        NSString *setPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", set.code]];
        [self createDir:setPath];
        
        for (NSString *rarity in rarities)
        {
            NSString *rarityPath = [setPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", rarity]];
            [self createDir:rarityPath];
            
            for (NSString *size in kImageSizes)
            {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mtgimage.com/symbol/set/%@/%@/%@.png", set.code, rarity, size]];
                NSString *filePath = [rarityPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.png", size]];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                {
                    NSLog(@"Downloading... %@", url);
                    [JJJUtil downloadResource:url toPath:filePath];
                }
            }
            
            //delete if empty
            NSArray *listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rarityPath error:nil];
            if (listOfFiles.count == 0)
            {
                [[NSFileManager defaultManager] removeItemAtPath:rarityPath error:nil];
            }
        }
    }
    
    [[Database sharedInstance] closeDb];
}

-(void) downloadSets:(NSArray*) arrSetCodes
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/images-raw/set"];
    NSArray *rarities = @[@"C", @"U", @"R", @"M", @"S"];
    
    [self createDir:path];
    
    for (NSString *setCode in arrSetCodes)
    {
        NSString *setPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", setCode]];
        [self createDir:setPath];
        
        for (NSString *rarity in rarities)
        {
            NSString *rarityPath = [setPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", rarity]];
            [self createDir:rarityPath];
            
            for (NSString *size in kImageSizes)
            {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mtgimage.com/symbol/set/%@/%@/%@.png", setCode, rarity, size]];
                NSString *filePath = [rarityPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.png", size]];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                {
                    NSLog(@"Downloading... %@", url);
                    [JJJUtil downloadResource:url toPath:filePath];
                }
            }
            
            //delete if empty
            NSArray *listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rarityPath error:nil];
            if (listOfFiles.count == 0)
            {
                [[NSFileManager defaultManager] removeItemAtPath:rarityPath error:nil];
            }
        }
    }
}

-(void) downloadCards
{
    [[Database sharedInstance] setupDb];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/images-raw/card"];
    
    [self createDir:path];
    
    for (Set *set in [Set MR_findAllSortedBy:@"releaseDate" ascending:YES])
    {
        NSString *setPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", set.code]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:setPath])
        {
            continue;
        }
        
        else
        {
            [self createDir:setPath];
            
            for (Card *card in set.cards)
            {
                
                NSString *filePath = [setPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.hq.jpg", card.imageName]];
                NSURL *url;
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                {
                    url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://mtgimage.com/set/%@/%@.hq.jpg", set.code, card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                    NSLog(@"Downloading... %@", url);
                    [JJJUtil downloadResource:url toPath:filePath];
                }
                
                filePath = [setPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.crop.jpg", card.imageName]];
                if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                {
                    url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://mtgimage.com/set/%@/%@.crop.jpg", set.code, card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    NSLog(@"Downloading... %@", url);
                    [JJJUtil downloadResource:url toPath:filePath];
                }
            }
            
            //delete if empty
            NSArray *listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:setPath error:nil];
            if (listOfFiles.count == 0)
            {
                [[NSFileManager defaultManager] removeItemAtPath:setPath error:nil];
            }
        }
    }
    
    [[Database sharedInstance] closeDb];
}

-(void) convertCardsToLowResolution
{
    NSDate *dateStart = [NSDate date];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *inputDir = [documentsDirectory stringByAppendingPathComponent:@"/images-raw/card"];
    NSString *cardDir = [documentsDirectory stringByAppendingPathComponent:@"/images-low/card"];
    
    for (NSString *dir in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inputDir error:nil])
    {
        NSString *inputPath = [inputDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", dir]];
        NSString *cardPath = [cardDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", dir]];
        
        for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inputPath error:nil])
        {
            NSString *input = [inputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:input];
            NSString *output;
            CGFloat quality = 0;
            
            if ([file rangeOfString:@".hq.jpg"].location != NSNotFound)
            {
                output = [cardPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", [file stringByReplacingOccurrencesOfString:@".hq.jpg" withString:@".jpg"]]];
                quality = image.size.width >= 480 ? 50 : 100;
            }
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:cardPath])
            {
                [self createDir:cardPath];
            }
            
            if (output && ![[NSFileManager defaultManager] fileExistsAtPath:output])
            {
                if (quality == 100)
                {
                    NSLog(@"copy %@ to %@", input, output);
                    [[NSFileManager defaultManager] copyItemAtPath:input toPath:output error:nil];
                }
                else
                {
                    [JJJUtil  runCommand:[NSString stringWithFormat:@"convert \"%@\" -strip -quality %.2f \"%@\"", input, quality, output]];
                }
            }
        }
    }
    
    NSDate *dateEnd = [NSDate date];
    NSTimeInterval timeDifference = [dateEnd timeIntervalSinceDate:dateStart];
    NSLog(@"Started: %@", dateStart);
    NSLog(@"Ended: %@", dateEnd);
    NSLog(@"Time Elapsed: %@",  [JJJUtil formatInterval:timeDifference]);
}

-(void) resizeCrops
{
    NSDate *dateStart = [NSDate date];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *inputDir = [documentsDirectory stringByAppendingPathComponent:@"/images-raw/card"];
    NSString *cropDir = [documentsDirectory stringByAppendingPathComponent:@"/images-low/crop"];
    
    for (NSString *dir in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inputDir error:nil])
    {
        NSString *inputPath = [inputDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", dir]];
        NSString *cropPath = [cropDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", dir]];
        
        for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inputPath error:nil])
        {
            NSString *input = [inputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
            NSString *output;
            NSString *output2x;
            
            if ([file rangeOfString:@".crop.jpg"].location != NSNotFound)
            {
                output = [cropPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", [file stringByReplacingOccurrencesOfString:@".crop.jpg" withString:@".jpg"]]];
                output2x = [cropPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", [file stringByReplacingOccurrencesOfString:@".crop.jpg" withString:@"@2x.jpg"]]];
            }

            if (![[NSFileManager defaultManager] fileExistsAtPath:cropPath])
            {
                [self createDir:cropPath];
            }
            
//            if (output && ![[NSFileManager defaultManager] fileExistsAtPath:output])
//            {
//                [JJJUtil  runCommand:[NSString stringWithFormat:@"convert \"%@\" -resize 40x40 \"%@\"", input, output]];
//            }
            if (output2x && ![[NSFileManager defaultManager] fileExistsAtPath:output2x])
            {
                [JJJUtil  runCommand:[NSString stringWithFormat:@"convert \"%@\" -resize 80x80 \"%@\"", input, output2x]];
            }
        }
    }
    
    NSDate *dateEnd = [NSDate date];
    NSTimeInterval timeDifference = [dateEnd timeIntervalSinceDate:dateStart];
    NSLog(@"Started: %@", dateStart);
    NSLog(@"Ended: %@", dateEnd);
    NSLog(@"Time Elapsed: %@",  [JJJUtil formatInterval:timeDifference]);
}

-(BOOL) createDir:(NSString*) path
{
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        return YES;
    }
    
    return NO;
}

@end

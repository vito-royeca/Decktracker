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
            
            NSLog(@"Downloading... %@", url);
            [JJJUtil downloadResource:url toPath:filePath];
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
            
            NSLog(@"Downloading... %@", url);
            [JJJUtil downloadResource:url toPath:filePath];
        }
    }
}

-(void) downloadSets
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
                
                NSLog(@"Downloading... %@", url);
                [JJJUtil downloadResource:url toPath:filePath];
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
    NSString *outputDir = [documentsDirectory stringByAppendingPathComponent:@"/images-low"];
    
    for (NSString *dir in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inputDir error:nil])
    {
        NSString *inputPath = [inputDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", dir]];
        NSString *outputPath = [outputDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", dir]];
        
        for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inputPath error:nil])
        {
            NSString *input = [inputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:input];
            NSString *output;
            CGFloat quality = 0;
            
            /*if ([file rangeOfString:@".crop.jpg"].location != NSNotFound)
            {
                outputPath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/crop"]];
                output = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", [file stringByReplacingOccurrencesOfString:@".crop.jpg" withString:@".jpg"]]];
                quality = 20;
            }
            else */if ([file rangeOfString:@".hq.jpg"].location != NSNotFound)
            {
                outputPath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/card"]];
                output = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", [file stringByReplacingOccurrencesOfString:@".hq.jpg" withString:@".jpg"]]];
                quality = image.size.width >= 480 ? 10 : 50;
            }
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:outputPath])
            {
                [self createDir:outputPath];
            }
            
            if (output && ![[NSFileManager defaultManager] fileExistsAtPath:output])
            {
                [JJJUtil  runCommand:[NSString stringWithFormat:@"convert \"%@\" -strip -quality %.2f \"%@\"", input, quality, output]];
            }
            
            // reset outputPath
            outputPath = [outputDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", dir]];
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

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
            [self downloadResource:url toPath:filePath];
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
            [self downloadResource:url toPath:filePath];
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
                [self downloadResource:url toPath:filePath];
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
                NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://mtgimage.com/set/%@/%@.hq.jpg", set.code, card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                NSString *filePath = [setPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.hq.jpg", card.imageName]];
                
                NSLog(@"Downloading... %@", url);
                [self downloadResource:url toPath:filePath];
                
                url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://mtgimage.com/set/%@/%@.crop.jpg", set.code, card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                filePath = [setPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.crop.jpg", card.imageName]];
                NSLog(@"Downloading... %@", url);
                [self downloadResource:url toPath:filePath];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/images-low/card"];
    
    for (NSString *dir in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil])
    {
        NSString *setPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", dir]];
        
        for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:setPath error:nil])
        {
            if ([file rangeOfString:@".crop.jpg"].location != NSNotFound)
            {
                continue;
            }
            
            NSString *input = [setPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
            NSString *output = [input stringByReplacingOccurrencesOfString:@".hq.jpg" withString:@".jpg"];;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:output])
            {
                [[NSFileManager defaultManager] removeItemAtPath:output error:nil];
            }
            
            [JJJUtil  runCommand:[NSString stringWithFormat:@"convert \"%@\" -strip -quality 50 \"%@\"", input, output]];
            [[NSFileManager defaultManager] removeItemAtPath:input error:nil];
        }
    }
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

//
//  FileManager.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/21/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "FileManager.h"
#import "JJJ/JJJUtil.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation FileManager
{
    NSMutableArray *_downloadQueue;
    NSDictionary *_currentQueue;
}

static FileManager *_me;

+(id) sharedInstance
{
    if (!_me)
    {
        _me = [[FileManager alloc] init];
    }
    
    return _me;
}

-(id) init
{
    if (self = [super init])
    {
        _downloadQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) saveAdvanceQuery:(NSString*) name
             withFilters:(NSDictionary*) dictQuery
              andSorters:(NSDictionary*) dictSorter
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/Advance Search"];
    NSString *fileName = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.plist", name]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    
    NSArray *arrData = @[dictQuery, dictSorter];
    [arrData writeToFile:fileName atomically:YES];
}

-(NSArray*) findAdvanceSearchFiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/Advance Search"];
    NSMutableArray *arrSearchFiles = [[NSMutableArray alloc] init];
    
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil])
    {
        if ([[[file lastPathComponent] pathExtension] isEqualToString:@"plist"])
        {
            NSString *key = [[file lastPathComponent] stringByDeletingPathExtension];
            NSString *value = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
            
            [arrSearchFiles addObject:@{key : value}];
        }
    }
    
    return arrSearchFiles;
}

-(void) deleteAdvanceSearchFile:(NSString*) name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/Advance Search"];
    NSString *file = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.plist", name]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:file])
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
}

-(NSString*) cardPath:(Card*) card
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/card/%@/", card.set.code]];
    NSString *cardPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", card.name]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cardPath])
    {
        return [NSString stringWithFormat:@"%@/images/card_back.jpg", [[NSBundle mainBundle] bundlePath]];
    }
    else
    {
        return cardPath;
    }
}

-(NSString*) cropPath:(Card*) card
{
    return [NSString stringWithFormat:@"%@/images/crop/%@/%@.jpg", [[NSBundle mainBundle] bundlePath], card.set.code, card.imageName];
}

-(void) downloadCardImage:(Card*) card  withCompletion:(void (^)(void))completion
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/card/%@/", card.set.code]];
    NSString *cardPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", card.name]];
    BOOL bFound = YES;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
        bFound = NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:cardPath])
    {
        bFound = NO;
    }
    for (NSDictionary *dict in _downloadQueue)
    {
        if ([dict objectForKey:@"card"] == card)
        {
            bFound = YES;
            break;
        }
    }
    
    if (!bFound)
    {
        NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://mtgimage.com/set/%@/%@.jpg", card.set.code, card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:@[card, cardPath, url]
                                                                         forKeys:@[@"card", @"cardPath", @"url"]];
        if (completion)
        {
            [dict setObject:completion forKey:@"completion"];
        }
        
        [_downloadQueue insertObject:dict atIndex:0];
        [self processQueue];
    }
}

-(void) processQueue
{
    if (_downloadQueue.count == 0 || _currentQueue)
    {
        return;
    }
    
    _currentQueue = [_downloadQueue firstObject];
    void (^completion)(void) = [_currentQueue objectForKey:@"completion"];

    [_downloadQueue removeObject:_currentQueue];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        
        NSURL *url = [_currentQueue objectForKey:@"url"];
        NSString *cardPath = [_currentQueue objectForKey:@"cardPath"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:cardPath])
        {
            NSLog(@"Downloading %@", [url path]);
            NSDate *startDate = [NSDate date];
            [JJJUtil downloadResource:url toPath:cardPath];
            
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"Card Download"
                                                                 interval:@((int)(interval * 1000))
                                                                     name:nil
                                                                    label:nil] build]];
        }
        
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
        
        _currentQueue = nil;
        [self processQueue];
    });
}

@end

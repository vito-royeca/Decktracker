//
//  FileManager.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/21/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "FileManager.h"
#import "JJJ/JJJUtil.h"
#import "Database.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

#import <Dropbox/Dropbox.h>

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

-(NSString*) cardPath:(Card*) card
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/card/%@/", card.set.code]];
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.crop.jpg", card.name]];
}

-(NSString*) cardSetPath:(Card*) card
{
    return [NSString stringWithFormat:@"%@/images/set/%@/%@/48.png", [[NSBundle mainBundle] bundlePath], card.set.code, [[Database sharedInstance] cardRarityIndex:card]];
}

-(void) downloadCardImage:(Card*) card
{
    if (!card)
    {
        return;
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
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
        if (dict[@"card"] == card)
        {
            bFound = YES;
            break;
        }
    }
    
    if (!bFound)
    {
        NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://mtgimage.com/set/%@/%@.jpg", card.set.code, card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:@[card, cardPath, url]
                                                                         forKeys:@[@"card", @"path", @"url"]];
//        [_downloadQueue insertObject:dict atIndex:0];
        [_downloadQueue addObject:dict];
        [self processDownloadQueue];
    }
}

-(void) downloadCropImage:(Card*) card
{
    if (!card)
    {
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/card/%@/", card.set.code]];
    NSString *cropPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.crop.jpg", card.name]];
    BOOL bFound = YES;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
        bFound = NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:cropPath])
    {
        bFound = NO;
    }
    for (NSDictionary *dict in _downloadQueue)
    {
        if (dict[@"crop"] == card)
        {
            bFound = YES;
            break;
        }
    }
    
    if (!bFound)
    {
        NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://mtgimage.com/set/%@/%@.crop.jpg", card.set.code, card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:@[card, cropPath, url]
                                                                         forKeys:@[@"crop", @"path", @"url"]];
//        [_downloadQueue insertObject:dict atIndex:0];
        [_downloadQueue addObject:dict];
        [self processDownloadQueue];
    }
}

-(void) processDownloadQueue
{
    if (_downloadQueue.count == 0 || _currentQueue)
    {
        return;
    }
    
    _currentQueue = [_downloadQueue firstObject];
    [_downloadQueue removeObject:_currentQueue];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        
        NSURL *url = _currentQueue[@"url"];
        NSString *path = _currentQueue[@"path"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            NSLog(@"Downloading %@", url);
//            NSDate *startDate = [NSDate date];
            [JJJUtil downloadResource:url toPath:path];
            
//            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
//            id tracker = [[GAI sharedInstance] defaultTracker];
//            [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"Card Download"
//                                                                 interval:@((int)(interval * 1000))
//                                                                     name:nil
//                                                                    label:nil] build]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            Card *card = _currentQueue[@"card"];
            if (card)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kCardDownloadCompleted
                                                                    object:nil
                                                                  userInfo:@{@"card":card}];
            }
            
            card = _currentQueue[@"crop"];
            if (card)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kCropDownloadCompleted
                                                                    object:nil
                                                                  userInfo:@{@"card":card}];
            }
            
            _currentQueue = nil;
            [self processDownloadQueue];
        });
    });
}

-(NSArray*) loadKeywords
{
    NSString *path = [NSString stringWithFormat:@"%@/keywords.plist", [[NSBundle mainBundle] bundlePath]];
    
    return [[NSArray alloc] initWithContentsOfFile:path];
}

#pragma mark - Files

-(DBAccount*) dropboxAccount
{
    return [[DBAccountManager sharedManager] linkedAccount];
}

-(void) initFilesystem
{
    NSArray *folders = @[@"Advance Search", @"Decks", @"Collections"];
    
    DBAccount *account = [self dropboxAccount];
    if (account)
    {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
    for (NSString *folder in folders)
    {
        if (account)
        {
            DBPath *path = [[DBPath root] childPath:folder];
            [[DBFilesystem sharedFilesystem] createFolder:path error:nil];
        }
        else
        {
            NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", folder]];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                [[NSFileManager defaultManager] createDirectoryAtPath:path
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
            }
        }
        
        // copy existing files to Dropbox
        if (account)
        {
            NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", folder]];
            
            for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil])
            {
                DBPath *dbPath = [[DBPath root] childPath:[NSString stringWithFormat:@"/%@/%@", [path lastPathComponent], file]];
                DBFile *dbFile = [[DBFilesystem sharedFilesystem] createFile:dbPath error:nil];
                NSString *fullPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
                
                [dbFile writeContentsOfFile:fullPath
                                shouldSteal:NO
                                      error:nil];
            }
        }
    }
}

-(NSArray*) findFilesAtPath:(NSString*) path
{
    NSMutableArray *arrSearchFiles = [[NSMutableArray alloc] init];
    
    if ([self dropboxAccount])
    {
        for (DBFileInfo *info in [[DBFilesystem sharedFilesystem] listFolder:[[DBPath root] childPath:path] error:nil])
        {
            NSString *key = [[info path] name];
            
            if ([[key pathExtension] isEqualToString:@"json"])
            {
                [arrSearchFiles addObject:[key stringByDeletingPathExtension]];
            }
        }
    }
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
        
        
        for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:nil])
        {
            if ([[[file lastPathComponent] pathExtension] isEqualToString:@"json"])
            {
                NSString *key = [[file lastPathComponent] stringByDeletingPathExtension];
                
                [arrSearchFiles addObject:key];
            }
        }
    }
    
    return arrSearchFiles;
}

-(void) deleteFileAtPath:(NSString*) path
{
    if ([self dropboxAccount])
    {
        DBPath *dbPath = [[DBPath root] childPath:path];
        [[DBFilesystem sharedFilesystem] deletePath:dbPath error:nil];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *file = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", path]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file])
    {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
}

-(id) loadFileAtPath:(NSString*) path
{
    NSData *data;
    
    if ([self dropboxAccount])
    {
        DBPath *dbPath = [[DBPath root] childPath:path];
        DBFile *dbFile = [[DBFilesystem sharedFilesystem] openFile:dbPath error:nil];
        if (dbFile)
        {
            data = [dbFile readData:nil];
            [dbFile close];
        }
    }
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *file = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", path]];
        data = [NSData dataWithContentsOfFile:file];
    }

    return data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] : nil;
}

-(void) saveData:(id) data atPath:(NSString*) path
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", path]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        [[NSFileManager defaultManager] removeItemAtPath:fileName
                                                   error:nil];
    }
    
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:fileName
                                                                     append:NO];
    [outputStream open];
    
    [NSJSONSerialization writeJSONObject:data
                                toStream:outputStream
                                 options:0
                                   error:nil];
    [outputStream close];
    
    if ([self dropboxAccount])
    {
        DBPath *dbPath = [[DBPath root] childPath:path];
        DBFile *dbFile = [[DBFilesystem sharedFilesystem] openFile:dbPath error:nil];
        if (!dbFile)
        {
            dbFile = [[DBFilesystem sharedFilesystem] createFile:dbPath error:nil];
        }
        if (dbFile)
        {
            [dbFile writeContentsOfFile:fileName shouldSteal:NO error:nil];
        }
    }
}

@end

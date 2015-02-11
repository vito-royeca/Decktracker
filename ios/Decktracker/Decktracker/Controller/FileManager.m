//
//  FileManager.m
//  Decktracker
//
//  Created by Jovit Royeca on 8/21/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "FileManager.h"
#import "Database.h"
#import "InAppPurchase.h"
#import "Magic.h"

#import "AFHTTPRequestOperationManager.h"
#import <Dropbox/Dropbox.h>
#import <MobileCoreServices/MobileCoreServices.h>

#ifndef DEBUG
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#endif

@implementation FileManager
{
    NSMutableArray *_downloadQueue;
    int _cuncurrentDownloads;
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
        _cuncurrentDownloads = 0;
    }
    
    return self;
}

-(NSString*) tempPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths firstObject];
    NSString *tmp = [cacheDirectory stringByAppendingPathComponent:@"/tmp"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmp])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:tmp
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    return tmp;
}

-(NSString*) cardPath:(DTCard*) card
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths firstObject];
    NSString *path = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/card/%@/", card.set.code]];
    NSString *cardHQPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.hq.jpg", card.imageName]];
    NSString *cardPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", card.imageName]];
    NSString *cardBackPath = [NSString stringWithFormat:@"%@/images/cardback.hq.jpg", [[NSBundle mainBundle] bundlePath]];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:cardHQPath] ? cardHQPath : ([[NSFileManager defaultManager] fileExistsAtPath:cardPath] ? cardPath : cardBackPath);
}

-(NSString*) cropPath:(DTCard*) card
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths firstObject];
    NSString *path = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/crop/%@/", card.set.code]];
    NSString *cropHQPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.crop.hq.jpg", card.imageName]];
    NSString *cropPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.crop.jpg", card.imageName]];
    NSString *cropBackPath = [NSString stringWithFormat:@"%@/images/cropback.hq.jpg", [[NSBundle mainBundle] bundlePath]];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:cropHQPath] ? cropHQPath : ([[NSFileManager defaultManager] fileExistsAtPath:cropPath] ? cropPath : cropBackPath);
}

-(NSString*) cardSetPath:(DTCard*) card
{
    return [NSString stringWithFormat:@"%@/images/set/%@/%@/48.png", [[NSBundle mainBundle] bundlePath], card.set.code, [[Database sharedInstance] cardRarityIndex:card]];
}

-(NSString*) cardTypePath:(DTCard*) card
{
    NSString *typePath;
    
    for (NSString *type in CARD_TYPES_WITH_SYMBOL)
    {
        if ([card.type hasPrefix:type] || [card.type containsString:type])
        {
            typePath = [type lowercaseString];
        }
    }
    return [NSString stringWithFormat:@"%@/images/other/%@/48.png", [[NSBundle mainBundle] bundlePath], typePath];
}

-(NSString*) setPath:(DTSet*) set small:(BOOL) small
{
    NSArray *rarities = @[@"C", @"R", @"U", @"M", @"S"];
    
    for (NSString *rarity in rarities)
    {
        NSString *path = [NSString stringWithFormat:@"%@/images/set/%@/%@/%@.png", [[NSBundle mainBundle] bundlePath], set.code, rarity, small? @"48":@"96"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            return path;
        }
    }
    
    return nil;
}

-(void) downloadCardImage:(DTCard*) card immediately:(BOOL) immediately
{
    if (!card)
    {
        return;
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths firstObject];
    NSString *path = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/card/%@/", card.set.code]];
    NSString *cardPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", card.imageName]];
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
    
    NSDictionary *oldQueue;
    for (NSDictionary *dict in _downloadQueue)
    {
        if (dict[@"card"] == card)
        {
            oldQueue = dict;
            break;
        }
    }
    if (oldQueue)
    {
        [_downloadQueue removeObject:oldQueue];
//        _cuncurrentDownloads--;
    }
    
    if (!bFound)
    {
        NSURL *url;
        
        if (card.multiverseID && [card.multiverseID intValue] > 0)
        {
            url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://mtgimage.com/multiverseid/%@.jpg", card.multiverseID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        else
        {
            url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://mtgimage.com/set/%@/%@.jpg", card.set.code, card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:@[card, cardPath, url]
                                                                         forKeys:@[@"card", @"path", @"url"]];
        
        if (immediately)
        {
            [_downloadQueue insertObject:dict atIndex:0];
        }
        else
        {
            [_downloadQueue addObject:dict];
        }
        [self processDownloadQueue];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCardDownloadCompleted
                                                            object:nil
                                                          userInfo:@{@"card": card}];
    }
}

-(void) downloadCropImage:(DTCard*) card immediately:(BOOL) immediately
{
    if (!card)
    {
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths firstObject];
    NSString *path = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/crop/%@/", card.set.code]];
    NSString *cropPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.crop.jpg", card.imageName]];
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
    
    NSDictionary *oldQueue;
    for (NSDictionary *dict in _downloadQueue)
    {
        if (dict[@"card"] == card)
        {
            oldQueue = dict;
            break;
        }
    }
    if (oldQueue)
    {
        [_downloadQueue removeObject:oldQueue];
//        _cuncurrentDownloads--;
    }
    
    if (!bFound)
    {
        NSURL *url;
        
        if (card.multiverseID && [card.multiverseID intValue] > 0)
        {
            url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://mtgimage.com/multiverseid/%@.crop.jpg", card.multiverseID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        else
        {
            url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://mtgimage.com/set/%@/%@.crop.jpg", card.set.code, card.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:@[card, cropPath, url]
                                                                         forKeys:@[@"crop", @"path", @"url"]];
        
        if (immediately)
        {
            [_downloadQueue insertObject:dict atIndex:0];
        }
        else
        {
            [_downloadQueue addObject:dict];
        }

        [self processDownloadQueue];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCropDownloadCompleted
                                                            object:nil
                                                          userInfo:@{@"card": card}];
    }
}

-(void) processDownloadQueue
{
    if (_downloadQueue.count == 0 || _cuncurrentDownloads > kMaxCuncurrentDownloads)
    {
        return;
    }
    
    NSDictionary *currentQueue = [_downloadQueue firstObject];
    [_downloadQueue removeObject:currentQueue];
    
    NSURL *url = currentQueue[@"url"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSString *path = currentQueue[@"path"];
    
    NSLog(@"Downloading %@", url);

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        UIImage *image = responseObject;
        NSData *data;
        
        if ([path hasSuffix:@"jpg"]) {
            data = UIImageJPEGRepresentation(image, 1);
        } else if ([path hasSuffix:@"png"]) {
            data = UIImagePNGRepresentation(image);
        }
        
        if (data) {
            [data writeToFile:path atomically:YES];
        }
        
        
        DTCard *card = currentQueue[@"card"];
        if (card)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCardDownloadCompleted
                                                                object:nil
                                                              userInfo:@{@"card":card}];
        }
        
        card = currentQueue[@"crop"];
        if (card)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCropDownloadCompleted
                                                                object:nil
                                                              userInfo:@{@"card":card}];
        }
        
        _cuncurrentDownloads--;
        [self processDownloadQueue];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        _cuncurrentDownloads--;
        [self processDownloadQueue];
    }];
    
    _cuncurrentDownloads++;
    [operation start];
}

-(NSArray*) loadKeywords
{
    NSString *path = [NSString stringWithFormat:@"%@/keywords.plist", [[NSBundle mainBundle] bundlePath]];
    
    return [[NSArray alloc] initWithContentsOfFile:path];
}

#pragma mark - Files
-(void) moveFilesInDocumentsToCaches
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:nil])
    {
        if ([file hasPrefix:@"images"])
        {
            NSString *src = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
            NSString *dest = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
            NSError *error;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:dest])
            {
                [[NSFileManager defaultManager] removeItemAtPath:dest error:&error];
            }
            [[NSFileManager defaultManager] moveItemAtPath:src toPath:dest error:&error];
        }
    }
    
}

-(void) setupFilesystem:(FileSystem) fileSystem
{
    if (![self isFileSystemEnabled:fileSystem])
    {
        return;
    }
    
    switch (fileSystem)
    {
        case FileSystemDropbox:
        {
//            DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
            DBAccountManager *accountManager = [DBAccountManager sharedManager];
            
            if (!accountManager)
            {
                DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:kDropboxID
                                                                                 secret:kDropBoxSecret];
                [DBAccountManager setSharedManager:accountManager];
            }
            break;
        }
        
        default:
        {
            break;
        }
    }
}

-(BOOL) isFileSystemEnabled:(FileSystem) fileSystem
{
    switch (fileSystem)
    {
        case FileSystemLocal:
        {
            return YES;
        }
        case FileSystemDropbox:
        {
            return [[[NSUserDefaults standardUserDefaults] valueForKey:@"dropbox_preference"] boolValue];
        }
        default:
        {
            return NO;
        }
    }
}

-(BOOL) isFileSystemAvailable:(FileSystem) fileSystem
{
    switch (fileSystem)
    {
        case FileSystemLocal:
        {
            return YES;
        }
        case FileSystemDropbox:
        {
            return [[DBAccountManager sharedManager] linkedAccount] != nil;
        }
        default:
        {
            return NO;
        }
    }
}

-(void) connectToFileSystem:(FileSystem) fileSystem
         withViewController:(UIViewController*) viewController
{
    switch (fileSystem)
    {
        case FileSystemDropbox:
        {
            DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
            
            if (!account)
            {
                [[DBAccountManager sharedManager] linkFromController:viewController];
            }
            break;
        }
        default:
        {
            break;
        }
    }
}

-(void) disconnectFromFileSystem:(FileSystem) fileSystem
{
    switch (fileSystem)
    {
        case FileSystemDropbox:
        {
            NSString *key = @"dropbox_preference";
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:key];
            
            [[[DBAccountManager sharedManager] linkedAccount] unlink];
            [DBAccountManager setSharedManager:nil];
            break;
        }
        default:
        {
            break;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) uploadLocalFile:(NSString*) localPath
           toFileSystem:(FileSystem) fileSystem
                 atPath:(NSString*) filePath
{
    if (![self isFileSystemEnabled:fileSystem] ||
        ![self isFileSystemAvailable:fileSystem])
    {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        
        switch (fileSystem)
        {
            case FileSystemDropbox:
            {
                DBPath *dbPath = [[DBPath root] childPath:filePath];
                DBFile *dbFile = [[DBFilesystem sharedFilesystem] openFile:dbPath error:nil];
                if (!dbFile)
                {
                    dbFile = [[DBFilesystem sharedFilesystem] createFile:dbPath error:nil];
                }
                if (dbFile)
                {
                    [dbFile writeContentsOfFile:localPath shouldSteal:NO error:nil];
                }
                break;
            }
            default:
            {
                break;
            }
        }
    });
}

-(void) downloadFile:(NSString*) filePath
      fromFileSystem:(FileSystem) fileSystem
      toLocalPath:(NSString*) localPath
{
    if (![self isFileSystemEnabled:fileSystem] ||
        ![self isFileSystemAvailable:fileSystem])
    {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        
        switch (fileSystem)
        {
            case FileSystemDropbox:
            {
                DBPath *dbPath = [[DBPath root] childPath:filePath];
                DBFile *dbFile = [[DBFilesystem sharedFilesystem] openFile:dbPath error:nil];
                if (dbFile)
                {
                    NSData *data = [dbFile readData:nil];
                    [data writeToFile:localPath atomically:YES];
                    [dbFile close];
                }

                break;
            }
            default:
            {
                break;
            }
        }
    });
}

-(NSArray*) listFilesAtPath:(NSString*) path fromFileSystem:(FileSystem) fileSystem
{
    NSMutableArray *arrFiles = [[NSMutableArray alloc] init];

    if (![self isFileSystemEnabled:fileSystem] ||
        ![self isFileSystemAvailable:fileSystem])
    {
        return arrFiles;
    }
    
    switch (fileSystem)
    {
        case FileSystemLocal:
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths firstObject];
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];

            
            for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:nil])
            {
                BOOL bDir = NO;
                
                [[NSFileManager defaultManager] fileExistsAtPath:[fullPath stringByAppendingPathComponent:file]
                                                     isDirectory:&bDir];
                if (!bDir)
                {
                    [arrFiles addObject:file];
                }
            }
            break;
        }
        case FileSystemDropbox:
        {
            for (DBFileInfo *info in [[DBFilesystem sharedFilesystem] listFolder:[[DBPath root] childPath:path] error:nil])
            {
                NSString *key = [[info path] name];
                
                if (![info isFolder])
                {
                    [arrFiles addObject:key];
                }
            }
            break;
        }
        default:
        {
            break;
        }
    }
    
    return arrFiles;
}

-(void) initFilesystem:(FileSystem) fileSystem
{
    if (![self isFileSystemEnabled:fileSystem] ||
        ![self isFileSystemAvailable:fileSystem])
    {
        return;
    }
    
    switch (fileSystem)
    {
        case FileSystemLocal:
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths firstObject];
            
            for (NSString *folder in kFolders)
            {
                NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", folder]];
                
                // create folder if not yet existing
                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    [[NSFileManager defaultManager] createDirectoryAtPath:path
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:nil];
                }
                
                // copy the the Samples
                if ([folder isEqualToString:kFolders[0]])
                {
                    if (![[[NSUserDefaults standardUserDefaults] valueForKey:kHasAdvanceSearchSamples] boolValue])
                    {
                        for (NSString *file in [[NSBundle mainBundle] pathsForResourcesOfType:@"json"
                                                                                  inDirectory:@"Advance Search"])
                        {
                            NSString *dest = [path stringByAppendingPathComponent:[file lastPathComponent]];
                            
                            if (![[NSFileManager defaultManager] fileExistsAtPath:dest])
                            {
                                [[NSFileManager defaultManager] copyItemAtPath:file toPath:dest error:nil];
                            }
                        }
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
                                                                  forKey:kHasAdvanceSearchSamples];
                    }
                }
                else if ([folder isEqualToString:kFolders[1]])
                {
                    if (![[[NSUserDefaults standardUserDefaults] valueForKey:kHasDeckSamples] boolValue])
                    {
                        for (NSString *file in [[NSBundle mainBundle] pathsForResourcesOfType:@"json"
                                                                                  inDirectory:@"Decks"])
                        {
                            NSString *dest = [path stringByAppendingPathComponent:[file lastPathComponent]];
                            
                            if (![[NSFileManager defaultManager] fileExistsAtPath:dest])
                            {
                                [[NSFileManager defaultManager] copyItemAtPath:file toPath:dest error:nil];
                            }
                        }
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
                                                                  forKey:kHasDeckSamples];
                    }
                }
            }
            break;
        }
        case FileSystemDropbox:
        {
            DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
            if (account)
            {
                DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
                [DBFilesystem setSharedFilesystem:filesystem];
            }

            for (NSString *folder in kFolders)
            {
                DBPath *dbPath = [[DBPath root] childPath:[NSString stringWithFormat:@"/%@", folder]];
                [[DBFilesystem sharedFilesystem] createFolder:dbPath error:nil];
            }
            break;
        }
        default:
        {
            break;
        }
    }
}

-(void) syncFiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
    for (NSString *folder in kFolders)
    {
        NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", folder]];
        
        for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil])
        {
            for (FileSystem i=FileSystemBox; i<=FileSystemOneDrive; i++)
            {
                NSString *fullPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
                    
                [self uploadLocalFile:fullPath toFileSystem:i atPath:[NSString stringWithFormat:@"/%@/%@", folder, file]];
            }
        }
        
        for (FileSystem i=FileSystemBox; i<=FileSystemOneDrive; i++)
        {
            for (NSString *file in [self listFilesAtPath:[NSString stringWithFormat:@"/%@", folder] fromFileSystem:i])
            {
                NSString *localPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", file]];
                
//                if (![[NSFileManager defaultManager] fileExistsAtPath:localPath])
                {
                    [self downloadFile:[NSString stringWithFormat:@"/%@/%@", folder, file]
                        fromFileSystem:i
                           toLocalPath:localPath];
                }
            }
        }
    }
}

-(void) deleteFileAtPath:(NSString*) path
{
    for (FileSystem i=FileSystemLocal; i<=FileSystemOneDrive; i++)
    {
        if ([self isFileSystemEnabled:i] && [self isFileSystemAvailable:i])
        {
            switch (i)
            {
                case FileSystemLocal:
                {
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths firstObject];
                    NSString *file = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", path]];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:file])
                    {
                        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
                    }
                    break;
                }
                case FileSystemDropbox:
                {
                    DBPath *dbPath = [[DBPath root] childPath:path];
                    [[DBFilesystem sharedFilesystem] deletePath:dbPath error:nil];
                    break;
                }
                default:
                {
                    break;
                }
            }
        }
    }
}

-(id) loadFileAtPath:(NSString*) path
{
    NSData *data;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *file = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", path]];
    data = [NSData dataWithContentsOfFile:file];

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
    
    for (FileSystem i=FileSystemBox; i<=FileSystemOneDrive; i++)
    {
        if ([self isFileSystemEnabled:i] && [self isFileSystemAvailable:i])
        {
            [self uploadLocalFile:fileName toFileSystem:i atPath:path];
        }
    }
}

@end

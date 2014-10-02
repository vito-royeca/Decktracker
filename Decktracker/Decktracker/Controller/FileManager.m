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
#import "InAppPurchase.h"
#import "Magic.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

#import "BoxSDK.h"
#import <Dropbox/Dropbox.h>

#import <MobileCoreServices/MobileCoreServices.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@implementation FileManager
{
    NSMutableArray *_downloadQueue;
    NSDictionary *_currentQueue;
    GTLServiceDrive *_gtlServiceDrive;
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
    NSString *cardPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", card.multiverseID && [card.multiverseID intValue] > 0 ? card.multiverseID : card.name]];
    
    // let's delete old card image downloaded with cardName
    NSString *oldPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", card.name]];
    if (card.multiverseID && [card.multiverseID intValue] > 0 &&
        [[NSFileManager defaultManager] fileExistsAtPath:oldPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
    }
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cardPath])
    {
        return [NSString stringWithFormat:@"%@/images/cardback.hq.jpg", [[NSBundle mainBundle] bundlePath]];
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
    
    // let's delete old crop image downloaded with cardName
    NSString *oldPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.crop.jpg", card.name]];
    if (card.multiverseID && [card.multiverseID intValue] > 0 &&
        [[NSFileManager defaultManager] fileExistsAtPath:oldPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
    }
    
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.crop.jpg", card.multiverseID && [card.multiverseID intValue] > 0 ? card.multiverseID : card.name]];
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
    NSString *cardPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", card.multiverseID && [card.multiverseID intValue] > 0 ? card.multiverseID : card.name]];
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
    NSString *cropPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.crop.jpg", card.multiverseID && [card.multiverseID intValue] > 0 ? card.multiverseID : card.name]];
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
-(void) setupFilesystem:(FileSystem) fileSystem
{
    if (![self isFileSystemEnabled:fileSystem])
    {
        return;
    }
    
    switch (fileSystem)
    {
        case FileSystemBox:
        {
            [BoxSDK sharedSDK].OAuth2Session.clientID = kBoxID;
            [BoxSDK sharedSDK].OAuth2Session.clientSecret = kBoxSecret;
            
            break;
        }
        case FileSystemDropbox:
        {
            DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:kDropboxID
                                                                                 secret:kDropBoxSecret];
            [DBAccountManager setSharedManager:accountManager];
            break;
        }
        case FileSystemGoogleDrive:
        {
            _gtlServiceDrive = [[GTLServiceDrive alloc] init];
            _gtlServiceDrive.shouldFetchNextPages = YES;
            _gtlServiceDrive.retryEnabled = YES;
            
            _gtlServiceDrive.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kGoogleDriveKeychain
                                                                                                clientID:kGoogleDriveID
                                                                                            clientSecret:kGoogleDriveSecret];
            break;
        }
        case FileSystemICloud:
        {
            
            break;
        }
        case FileSystemOneDrive:
        {
            
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
        case FileSystemBox:
        {
            return [InAppPurchase isProductPurchased:CLOUD_STORAGE_IAP_PRODUCT_ID] &&
                [[[NSUserDefaults standardUserDefaults] valueForKey:@"box_preference"] boolValue];
        }
        case FileSystemDropbox:
        {
            return [InAppPurchase isProductPurchased:CLOUD_STORAGE_IAP_PRODUCT_ID] &&
                [[[NSUserDefaults standardUserDefaults] valueForKey:@"dropbox_preference"] boolValue];
        }
        case FileSystemGoogleDrive:
        {
            return [InAppPurchase isProductPurchased:CLOUD_STORAGE_IAP_PRODUCT_ID] &&
                [[[NSUserDefaults standardUserDefaults] valueForKey:@"google_drive_preference"] boolValue];
        }
        case FileSystemICloud:
        {
            return [InAppPurchase isProductPurchased:CLOUD_STORAGE_IAP_PRODUCT_ID] &&
                [[[NSUserDefaults standardUserDefaults] valueForKey:@"icloud_preference"] boolValue];
        }
        case FileSystemOneDrive:
        {
            return [InAppPurchase isProductPurchased:CLOUD_STORAGE_IAP_PRODUCT_ID] &&
                [[[NSUserDefaults standardUserDefaults] valueForKey:@"onedrive_preference"] boolValue];
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
        case FileSystemBox:
        {
            return NO;
        }
        case FileSystemDropbox:
        {
            return [[DBAccountManager sharedManager] linkedAccount] != nil;
        }
        case FileSystemGoogleDrive:
        {
            return _gtlServiceDrive.authorizer != nil;
        }
        case FileSystemICloud:
        {
            return NO;
        }
        case FileSystemOneDrive:
        {
            return NO;
        }
    }
}

-(void) connectToFileSystem:(FileSystem) fileSystem
         withViewController:(UIViewController*) viewController
{
    if (![InAppPurchase isProductPurchased:CLOUD_STORAGE_IAP_PRODUCT_ID])
    {
        return;
    }
    
    switch (fileSystem)
    {
        case FileSystemBox:
        {
            UIViewController *authController = [[BoxAuthorizationViewController alloc] initWithAuthorizationURL:[[BoxSDK sharedSDK].OAuth2Session authorizeURL] redirectURI:nil];
            [viewController.navigationController pushViewController:authController animated:NO];
            break;
        }
        case FileSystemDropbox:
        {
            DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
            
            if (!account)
            {
                [[DBAccountManager sharedManager] linkFromController:viewController];
            }
            break;
        }
        case FileSystemGoogleDrive:
        {
            if ([((GTMOAuth2Authentication*) _gtlServiceDrive.authorizer) canAuthorize])
            {
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES]
                                                         forKey:@"google_drive_preference"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[FileManager sharedInstance] initFilesystem:FileSystemGoogleDrive];
                [[FileManager sharedInstance] syncFiles];
            }
            else
            {
                GTMOAuth2ViewControllerTouch *authController;
                
                authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                                                            clientID:kGoogleDriveID
                                                                        clientSecret:kGoogleDriveSecret
                                                                    keychainItemName:kGoogleDriveKeychain
                                                                            delegate:self
                                                                    finishedSelector:@selector(viewController:finishedWithAuth:error:)];
                
                [viewController.navigationController pushViewController:authController animated:NO];
            }
            break;
        }
        case FileSystemICloud:
        {
            break;
        }
        case FileSystemOneDrive:
        {
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil)
    {
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kGoogleDriveKeychain];
        _gtlServiceDrive.authorizer = nil;
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"google_drive_preference"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        _gtlServiceDrive.authorizer = authResult;
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"google_drive_preference"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[FileManager sharedInstance] initFilesystem:FileSystemGoogleDrive];
        [[FileManager sharedInstance] syncFiles];
    }
}


-(void) disconnectFromFileSystem:(FileSystem) fileSystem
{
    if (![InAppPurchase isProductPurchased:CLOUD_STORAGE_IAP_PRODUCT_ID])
    {
        return;
    }

    switch (fileSystem)
    {
        case FileSystemBox:
        {
            NSString *key = @"box_preference";
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:key];
            
            break;
        }
        case FileSystemDropbox:
        {
            NSString *key = @"dropbox_preference";
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:key];
            
            [[[DBAccountManager sharedManager] linkedAccount] unlink];
            break;
        }
        case FileSystemGoogleDrive:
        {
            NSString *key = @"google_drive_preference";
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:key];
            
            _gtlServiceDrive.authorizer = nil;
            
            break;
        }
        case FileSystemICloud:
        {
            NSString *key = @"icloud_preference";
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:key];
            
            break;
        }
        case FileSystemOneDrive:
        {
            NSString *key = @"onedrive_preference";
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:key];
            
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
            case FileSystemBox:
            {
                
                break;
            }
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
            case FileSystemGoogleDrive:
            {
                
                break;
            }
            case FileSystemICloud:
            {
                
                break;
            }
            case FileSystemOneDrive:
            {
                
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
            case FileSystemBox:
            {
                
                break;
            }
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
            case FileSystemGoogleDrive:
            {
                
                break;
            }
            case FileSystemICloud:
            {
                
                break;
            }
            case FileSystemOneDrive:
            {
                
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
        }
        case FileSystemBox:
        {
            
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
        case FileSystemGoogleDrive:
        {
            
            break;
        }
        case FileSystemICloud:
        {
            
            break;
        }
        case FileSystemOneDrive:
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
            }
            break;
        }
        case FileSystemBox:
        {
            
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

        case FileSystemGoogleDrive:
        {
            NSString *parentID;
            
            GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
            query.q = @"mimeType = 'application/pdf'"; //@"'root' in parents and trashed=false";
            [_gtlServiceDrive executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                          GTLDriveFileList *files,
                                                          NSError *error)
            {
                if (!error)
                {
                    NSArray *arrFiles = [[NSArray alloc] initWithArray:files.items];
                    
                    for (GTLDriveFile *file in arrFiles)
                    {
                        NSLog(@"%@ = %@", file.identifier, file.title);
                        
                    }
                }
            }];
            
            // create parent folder first
//            GTLDriveFile *gFolder = [GTLDriveFile object];
//            gFolder.title = kGoogleDriveKeychain;
//            gFolder.mimeType = @"application/vnd.google-apps.folder";
//            
//            GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:gFolder uploadParameters:nil];
//            [_gtlServiceDrive executeQuery:query
//                         completionHandler:^(GTLServiceTicket *ticket,
//                                             GTLDriveFile *updatedFile,
//                                             NSError *error)
//            {
//                if (error)
//                {
//                    NSLog(@"An error occurred: %@", error);
//                }
//                else
//                {
//                    GTLDriveParentReference *parent = [GTLDriveParentReference object];
//                    parent.identifier = updatedFile.identifier;
//                    
//                    for (NSString *folder in kFolders)
//                    {
//                        GTLDriveFile *gFolder2 = [GTLDriveFile object];
//                        gFolder2.title = folder;
//                        gFolder2.mimeType = @"application/vnd.google-apps.folder";
//                        gFolder2.parents = @[parent];
//                        
//                        GTLQueryDrive *query2 = [GTLQueryDrive queryForFilesInsertWithObject:gFolder2 uploadParameters:nil];
//                        [_gtlServiceDrive executeQuery:query2
//                                     completionHandler:^(GTLServiceTicket *ticket,
//                                                         GTLDriveFile *updatedFile,
//                                                         NSError *error)
//                         {
//                             if (error)
//                             {
//                                 NSLog(@"An error occurred: %@", error);
//                             }
//                         }];
//                    }
//                }
//             }];
            

             break;
        }
        case FileSystemICloud:
        {
            
            break;
        }
        case FileSystemOneDrive:
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
                    
                [self uploadLocalFile:fullPath toFileSystem:i atPath:[NSString stringWithFormat:@"/%@", file]];
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
                case FileSystemBox:
                {

                    break;
                }
                case FileSystemDropbox:
                {
                    DBPath *dbPath = [[DBPath root] childPath:path];
                    [[DBFilesystem sharedFilesystem] deletePath:dbPath error:nil];
                    break;
                }
                case FileSystemGoogleDrive:
                {
                    
                    break;
                }
                case FileSystemICloud:
                {
                    break;
                }
                case FileSystemOneDrive:
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
//    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
//    
//    if (account)
//    {
//        DBPath *dbPath = [[DBPath root] childPath:path];
//        DBFile *dbFile = [[DBFilesystem sharedFilesystem] openFile:dbPath error:nil];
//        if (dbFile)
//        {
//            data = [dbFile readData:nil];
//            [dbFile close];
//        }
//    }
//    else
//    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *file = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", path]];
        data = [NSData dataWithContentsOfFile:file];
//    }

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

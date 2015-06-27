//
//  FileManager.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/21/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import Foundation;

#import "DTCard.h"
#import "DTSet.h"

#import "JJJ/JJJ.h"

#define kCardDownloadCompleted           @"kCardDownloadCompleted"
#define kFolders                         @[@"Advance Search", @"Decks", @"Collections"]
#define kHasAdvanceSearchSamples         @"HasAdvanceSearchSamples"
#define kHasDeckSamples                  @"HasDeckSamples"

#define kMaxCuncurrentDownloads          6

typedef NS_ENUM(NSInteger, FileSystem)
{
    FileSystemLocal,
    FileSystemBox,
    FileSystemDropbox,
    FileSystemGoogleDrive,
    FileSystemICloud,
    FileSystemOneDrive
};

@interface FileManager : NSObject

+(id) sharedInstance;

- (NSString*) tempPath;
- (NSString*) cardPath:(NSString*) cardId forLanguage:(NSString*) languageName;
- (NSString*) cardPath:(NSString*) cardId;
- (NSString*) cropPath:(NSString*) cardId;
- (NSString*) cardSetPath:(NSString*) cardId;
- (NSString*) cardTypePath:(NSString*) cardId;
- (NSString*) setPath:(NSString*) setId small:(BOOL) small;
- (void) downloadCardImage:(NSString*) cardId immediately:(BOOL) immediately;
- (void) downloadCardImage:(NSString*) cardId
               forLanguage:(NSString*) languageName
               immediately:(BOOL) immediately;
- (void) createCropForCard:(NSString*) cardId;
- (NSArray*) loadKeywords;
- (NSArray*) manaImagesForCard:(NSString*) cardId;

- (void) connectToFileSystem:(FileSystem) fileSystem
         withViewController:(UIViewController*) viewController;
- (void) disconnectFromFileSystem:(FileSystem) fileSystem;

- (void) moveFilesInDocumentsToCaches;
- (void) initFilesystem:(FileSystem) fileSystem;
- (void) setupFilesystem:(FileSystem) fileSystem;
- (void) syncFiles;
- (NSArray*) listFilesAtPath:(NSString*) path fromFileSystem:(FileSystem) fileSystem;
- (void) deleteFileAtPath:(NSString*) path;
- (id) loadFileAtPath:(NSString*) path;
- (void) saveData:(id) data atPath:(NSString*) path;

@end

//
//  FileManager.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/21/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import Foundation;

#import "Card.h"
#import "Set.h"

#import "JJJ/JJJ.h"

#define kCardDownloadCompleted           @"kCardDownloadCompleted"
#define kCropDownloadCompleted           @"kCropDownloadCompleted"
#define kFolders                         @[@"Advance Search", @"Decks", @"Collections"]
#define kHasAdvanceSearchSamples         @"HasAdvanceSearchSamples"
#define kHasDeckSamples                  @"HasDeckSamples"

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

-(NSString*) cardPath:(Card*) card;
-(NSString*) cropPath:(Card*) card;
-(NSString*) cardSetPath:(Card*) card;
-(NSString*) cardSetPathBig:(Set*) set;
-(void) downloadCardImage:(Card*) card immediately:(BOOL) immediately;
-(void) downloadCropImage:(Card*) card immediately:(BOOL) immediately;
-(NSArray*) loadKeywords;

-(void) connectToFileSystem:(FileSystem) fileSystem
         withViewController:(UIViewController*) viewController;
-(void) disconnectFromFileSystem:(FileSystem) fileSystem;

-(void) moveFilesInDocumentsToCaches;
-(void) initFilesystem:(FileSystem) fileSystem;
-(void) setupFilesystem:(FileSystem) fileSystem;
-(void) syncFiles;
-(NSArray*) listFilesAtPath:(NSString*) path fromFileSystem:(FileSystem) fileSystem;
-(void) deleteFileAtPath:(NSString*) path;
-(id) loadFileAtPath:(NSString*) path;
-(void) saveData:(id) data atPath:(NSString*) path;

@end

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

-(NSString*) tempPath;
-(NSString*) cardPath:(DTCard*) card;
-(NSString*) cropPath:(DTCard*) card;
-(NSString*) cardSetPath:(DTCard*) card;
-(NSString*) cardTypePath:(DTCard*) card;
-(NSString*) setPath:(DTSet*) set small:(BOOL) small;
-(void) downloadCardImage:(DTCard*) card immediately:(BOOL) immediately;
-(void) downloadCropImage:(DTCard*) card immediately:(BOOL) immediately;
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

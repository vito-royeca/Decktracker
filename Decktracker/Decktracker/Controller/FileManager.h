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

#define kBoxID                           @"v3vx3t10k6genv8ao7r5f3rqunz23atm"
#define kBoxSecret                       @"foPhGtidtVObEBEbNd2FZIbxk9nKSu99"

#define kDropboxID                       @"v57bkxsnzi3gxt3"
#define kDropBoxSecret                   @"qbyj5znuytk3ljj"

#define kGoogleDriveID                   @"885791360366-rvgaob5mp4vpsghbilg7mrfqc1lsind8.apps.googleusercontent.com"
#define kGoogleDriveSecret               @"zqynI0KVtpRhl6JVd5RrSP82"
#define kGoogleDriveKeychain             @"Decktracker"

#define kOneDriveID                      @""
#define kOneDriveSecret                  @""


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

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

#define kCardDownloadCompleted           @"kCardDownloadCompleted"
#define kCropDownloadCompleted           @"kCropDownloadCompleted"

@interface FileManager : NSObject

+(id) sharedInstance;

-(NSString*) cardPath:(Card*) card;
-(NSString*) cropPath:(Card*) card;
-(NSString*) cardSetPath:(Card*) card;
-(void) downloadCardImage:(Card*) card;
-(void) downloadCropImage:(Card*) card;
-(NSArray*) loadKeywords;

-(void) initFilesystem;
-(NSArray*) findFilesAtPath:(NSString*) path;
-(void) deleteFileAtPath:(NSString*) path;
-(id) loadFileAtPath:(NSString*) path;
-(void) saveData:(id) data atPath:(NSString*) path;

@end

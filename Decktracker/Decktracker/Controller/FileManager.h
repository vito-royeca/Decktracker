//
//  FileManager.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/21/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "Set.h"

@interface FileManager : NSObject

+(id) sharedInstance;

-(NSString*) cardPath:(Card*) card;
-(NSString*) cropPath:(Card*) card;
-(NSString*) cardSetPath:(Card*) card;
-(void) downloadCardImage:(Card*) card  withCompletion:(void (^)(void))completion;
-(void) downloadCropImage:(Card*) card  withCompletion:(void (^)(void))completion;
-(NSArray*) loadKeywords;

-(void) initFilesystem;
-(NSArray*) findFilesAtPath:(NSString*) path;
-(void) deleteFileAtPath:(NSString*) path;
-(id) loadFileAtPath:(NSString*) path;
-(void) saveData:(id) data atPath:(NSString*) path;

@end

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

-(void) saveAdvanceQuery:(NSString*) name
             withFilters:(NSDictionary*) dictQuery
              andSorters:(NSDictionary*) dictSorter;

-(NSArray*) findAdvanceSearchFiles;
-(void) deleteAdvanceSearchFile:(NSString*) name;
-(NSString*) cardPath:(Card*) card;
-(NSString*) cropPath:(Card*) card;
-(NSString*) cardSetPath:(Card*) card;
-(void) downloadCardImage:(Card*) card  withCompletion:(void (^)(void))completion;
-(NSArray*) loadKeywords;

@end

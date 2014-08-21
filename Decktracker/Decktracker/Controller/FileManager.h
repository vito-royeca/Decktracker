//
//  FileManager.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/21/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+(id) sharedInstance;

-(void) saveAdvanceQuery:(NSString*) name
             withFilters:(NSDictionary*) dictQuery
              andSorters:(NSDictionary*) dictSorter;

-(NSArray*) findAdvanceSearchFiles;

@end

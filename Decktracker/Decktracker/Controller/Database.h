//
//  Database.h
//  DeckTracker
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JJJ/JJJ.h"

#define kFetchBatchSize       100
#define kDatabaseStore        @"database.sqlite"

@interface Database : NSObject

+ (id)sharedInstance;

-(void) setupDb;
-(void) closeDb;

#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
-(NSFetchedResultsController*) search:(NSString*)query;
#endif

@end

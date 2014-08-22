//
//  Version.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/22/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Version : NSManagedObject

@property (nonatomic, retain) NSString * dataSet;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * version;

@end

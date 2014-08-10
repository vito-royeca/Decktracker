//
//  SetType.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/8/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Set;

@interface SetType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Set *set;

@end

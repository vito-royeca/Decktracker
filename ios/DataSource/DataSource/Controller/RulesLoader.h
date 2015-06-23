//
//  RulesLoader.h
//  DataSource
//
//  Created by Jovit Royeca on 11/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTComprehensiveGlossary.h"
#import "DTComprehensiveRule.h"

#import <Realm/Realm.h>

@interface RulesLoader : NSObject

-(void) json2Database;

@end

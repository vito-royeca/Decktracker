//
//  JSONLoader.h
//  DataSource
//
//  Created by Jovit Royeca on 8/2/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import Foundation;

#import "DTArtist.h"
#import "DTBlock.h"
#import "DTCard.h"
#import "DTCardColor.h"
#import "DTCardForeignName.h"
#import "DTCardLegality.h"
#import "DTCardRarity.h"
#import "DTCardRuling.h"
#import "DTCardType.h"
#import "DTLanguage.h"
#import "DTFormat.h"
#import "DTSet.h"
#import "DTSetType.h"

#import <Realm/Realm.h>

@interface JSONLoader : NSObject

-(void) json2Database;

@end

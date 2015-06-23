//
//  ImageLoader.h
//  DataSource
//
//  Created by Jovit Royeca on 8/3/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import Foundation;

@interface ImageLoader : NSObject

-(void) downloadSymbols;
-(void) downloadOtherSymbols;
-(void) downloadAllSets;
-(void) downloadSetIcons:(NSArray*) arrSetCodes;
-(void) downloadCards;
-(void) convertCardsToLowResolution;
-(void) resizeCrops;

@end

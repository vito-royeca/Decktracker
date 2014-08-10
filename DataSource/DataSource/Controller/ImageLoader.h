//
//  ImageLoader.h
//  DataSource
//
//  Created by Jovit Royeca on 8/3/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageLoader : NSObject

-(void) downloadSymbols;
-(void) downloadOtherSymbols;
-(void) downloadSets;
-(void) downloadCards;
-(void) convertCardsToLowResolution;

@end

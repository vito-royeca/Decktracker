//
//  SearchResultsTableViewCell.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/24/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "DTCard.h"
#import "Constants.h"
#import "DTCardType.h"
#import "DTSet.h"
#import "Database.h"

#import "JJJ/JJJ.h"

#define SEARCH_RESULTS_CELL_HEIGHT            95

@interface SearchResultsTableViewCell : UITableViewCell

@property(strong,nonatomic) IBOutlet UILabel *lblRank;
@property(strong,nonatomic) IBOutlet UIImageView *imgCrop;
@property(strong,nonatomic) IBOutlet UILabel *lblCardName;
@property(strong,nonatomic) IBOutlet UILabel *lblDetail;
@property(strong,nonatomic) IBOutlet UILabel *lblSet;
@property(strong,nonatomic) IBOutlet UIView *viewManaCost;
@property(strong,nonatomic) IBOutlet UIImageView *imgSet;
@property(strong,nonatomic) IBOutlet UILabel *lblBadge;
@property(strong,nonatomic) IBOutlet UIView *viewRating;
@property(strong,nonatomic) IBOutlet UILabel *lblLowPrice;
@property(strong,nonatomic) IBOutlet UILabel *lblMedianPrice;
@property(strong,nonatomic) IBOutlet UILabel *lblHighPrice;
@property(strong,nonatomic) IBOutlet UILabel *lblFoilPrice;
@property(strong,nonatomic) IBOutlet UIImageView *imgType;

@property(strong,nonatomic) NSString *cardId;

-(void) displayCard:(NSString*) cardId;
-(void) addBadge:(int) badgeValue;
-(void) addRank:(int) rankValue;
//-(void) updatePricing;

@end

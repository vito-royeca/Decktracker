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
@property (weak, nonatomic) IBOutlet UILabel *lblLowPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblMedianPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblHighPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblFoilPrice;
@property (weak, nonatomic) IBOutlet UIImageView *imgType;


-(void) displayCard:(DTCard*) card;
-(void) addBadge:(int) badgeValue;
-(void) addRank:(int) rankValue;
//-(void) updatePricing;

@end

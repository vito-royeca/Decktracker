//
//  SearchResultsTableViewCell.h
//  Decktracker
//
//  Created by Jovit Royeca on 8/24/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "DTCard.h"
#import "DTCardType.h"
#import "DTSet.h"
#import "Database.h"
#import "Magic.h"

#import "JJJ/JJJ.h"

#define SEARCH_RESULTS_CELL_HEIGHT            80

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


-(void) displayCard:(DTCard*) card;
-(void) addBadge:(int) badgeValue;
-(void) addRank:(int) rankValue;

@end

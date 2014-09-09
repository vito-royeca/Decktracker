//
//  AddCardViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "QuantityTableViewCell.h"

@interface AddCardViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, QuantityTableViewCellDelegate>

@property(strong,nonatomic) UISegmentedControl *segmentedControl;
@property(strong,nonatomic) UITableView *tblAddTo;
@property(strong, nonatomic) UIBarButtonItem *btnCancel;
@property(strong, nonatomic) UIBarButtonItem *btnDone;
@property(strong,nonatomic) UIBarButtonItem *btnShowCard;
@property(strong,nonatomic) UIToolbar *bottomToolbar;

@property(strong,nonatomic) Card *card;
@property(strong,nonatomic) NSMutableArray *arrDecks;
@property(strong,nonatomic) NSMutableArray *arrCollections;

@property(nonatomic) int segmentedControlIndex;
@property(nonatomic) int selectedDeckIndex;
@property(nonatomic) int selectedCollectionIndex;
@property(nonatomic) BOOL addDeckButtonVisible;
@property(nonatomic) BOOL addCollectionButtonVisible;
@property(nonatomic) BOOL showCardButtonVisible;

@end

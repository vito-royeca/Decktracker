//
//  AddToDeckViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/3/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "QuantityTableViewCell.h"

@interface AddToDeckViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, QualityTableViewCellDelegate>

@property(strong,nonatomic) UITableView *tblAddTo;
@property(strong, nonatomic) UIBarButtonItem *btnCancel;
@property(strong, nonatomic) UIBarButtonItem *btnDone;
@property(strong,nonatomic) UIBarButtonItem *btnNew;
@property(strong,nonatomic) UIBarButtonItem *btnShowCard;
@property(strong,nonatomic) UIToolbar *bottomToolbar;

@property(strong,nonatomic) NSMutableArray *arrDecks;
@property(strong,nonatomic) Card *card;
@property(nonatomic) int selectedDeckIndex;
@property(nonatomic) BOOL newButtonVisible;
@property(nonatomic) BOOL showCardButtonVisible;

@end

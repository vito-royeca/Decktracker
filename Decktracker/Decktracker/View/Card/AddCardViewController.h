//
//  AddCardViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/9/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "DTCard.h"
#import "InAppPurchaseViewController.h"
#import "MBProgressHUD.h"
#import "QuantityTableViewCell.h"

@interface AddCardViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, QuantityTableViewCellDelegate, MBProgressHUDDelegate, InAppPurchaseViewControllerDelegate>

@property(strong,nonatomic) UISegmentedControl *segmentedControl;
@property(strong,nonatomic) UITableView *tblAddTo;
@property(strong,nonatomic) UIBarButtonItem *btnCancel;
@property(strong,nonatomic) UIBarButtonItem *btnDone;
@property(strong,nonatomic) UIBarButtonItem *btnShowCard;
@property(strong,nonatomic) UIBarButtonItem *btnCreate;
@property(strong,nonatomic) UIToolbar *bottomToolbar;

@property(strong,nonatomic) DTCard *card;
@property(strong,nonatomic) NSMutableArray *arrDecks;
@property(strong,nonatomic) NSMutableArray *arrCollections;

@property(nonatomic) int segmentedControlIndex;
@property(nonatomic) int selectedDeckIndex;
@property(nonatomic) int selectedCollectionIndex;
@property(nonatomic) BOOL createButtonVisible;
@property(nonatomic) BOOL showCardButtonVisible;

@end

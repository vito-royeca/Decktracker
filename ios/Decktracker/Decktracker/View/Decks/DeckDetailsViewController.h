//
//  DeckDetailsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "Deck.h"

#import "IASKSettingsReader.h"
#import "IASKAppSettingsViewController.h"
#import "InAppPurchaseViewController.h"

typedef NS_ENUM(NSInteger, DeckDetailsViewMode)
{
    DeckDetailsViewModeList,
    DeckDetailsViewModeGrid
};

@interface DeckDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, IASKSettingsDelegate, InAppPurchaseViewControllerDelegate>

@property(strong,nonatomic) UIBarButtonItem *btnBack;
@property(strong,nonatomic) UIBarButtonItem *btnView;
@property(strong,nonatomic) UISegmentedControl *segmentedControl;
@property(strong,nonatomic) UITableView *tblCards;
@property(strong,nonatomic) IASKAppSettingsViewController *cardDetailsViewController;

@property(strong,nonatomic) Deck *deck;

@end

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


@interface DeckDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, IASKSettingsDelegate>

@property(strong,nonatomic) UIBarButtonItem *btnBack;
@property(strong,nonatomic) UISegmentedControl *segmentedControl;
@property(strong,nonatomic) UITableView *tblCards;
@property(strong,nonatomic) IASKAppSettingsViewController *cardDetailsViewController;

@property(strong,nonatomic) Deck *deck;

@end

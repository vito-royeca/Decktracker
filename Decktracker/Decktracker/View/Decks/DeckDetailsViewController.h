//
//  DeckDetailsViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

@import UIKit;

#import "Deck.h"
#import "FieldEditorViewController.h"

@interface DeckDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, FieldEditorViewControllerDelegate>

@property(strong,nonatomic) Deck *deck;
@property(strong,nonatomic) UISegmentedControl *segmentedControl;
@property(strong,nonatomic) UITableView *tblCards;
@property(strong, nonatomic) UIToolbar *bottomToolbar;

@end
